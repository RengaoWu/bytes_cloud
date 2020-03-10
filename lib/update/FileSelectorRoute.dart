import 'dart:convert';
import 'dart:io';

import 'package:bytes_cloud/common.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileIoslateMethods.dart';
import 'package:bytes_cloud/utils/FileTypeUtils.dart';
import 'package:bytes_cloud/utils/Json.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

class TypeSelectorRoute extends StatefulWidget {
  String arg_type;
  TypeSelectorRoute(this.arg_type);
  @override
  State<StatefulWidget> createState() {
    return TypeSelectorRouteState(arg_type);
  }
}

class TypeSelectorRouteState extends State<TypeSelectorRoute> {
  String arg_type;
  List<String> selectedFiles = [];
  int filesSize = 0;

  Future<List<FileSystemEntity>> getAllFile(String path) async {
    try {
      Map<String, dynamic> args = {
        'ext': extensionName2Type.keys.toList(),
        'path': path
      };
      return await compute(wapperGetAllFiles, args);
    } catch (err) {
      print(err);
    }
  }

  String currentType = Constants.TYPE_ALL;
  List<FileSystemEntity> allFiles = [];
  Map<String, Widget> type2Icon = {};
  Map<String, String> extensionName2Type = {};

  // initState 初始化
  Map<String, List<FileSystemEntity>> type2Files = {};

  filterTypeFiles() {
    allFiles.forEach((file) {
      String extension = file.path.substring(file.path.lastIndexOf('.'));
      if (extension != null && extensionName2Type.keys.contains(extension)) {
        type2Files[extensionName2Type[extension]].add(file);
      }
    });
  }

  TypeSelectorRouteState(this.arg_type);
  initData() {
    // // convert
    FileTypeUtils.convert(arg_type, type2Icon, extensionName2Type);
    type2Icon.keys.forEach((key) {
      type2Files[key] = [];
    });
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Icon(Icons.arrow_left),
          onTap: () => Navigator.pop(context),
        ),
        title: Text('$currentType'),
        centerTitle: true,
        actions: <Widget>[
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.file_upload),
                onPressed: () {
                  pushToCloud(context);
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          fileTypeGridView(),
          allFiles.length == 0 ? loadFilesFuture() : fileList(),
          Padding(
              padding: EdgeInsets.all(4),
              child: Center(
                child:
                    Text('上传到ByteCloud，总共${Common().getFileSize(filesSize)}'),
              ))
          //Expanded(child: FileSelectorFragment()),
        ],
      ),
    );
  }

  pushToCloud(BuildContext context) {
    String content = '';
    if (selectedFiles.length == 0) {
      content = '没有选择任何文件';
    } else {
      content =
          '开始上传，总共${selectedFiles.length}个文件，共${Common().getFileSize(filesSize)}';
    }
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(content)));
  }

  loadFilesFuture() {
    return FutureBuilder(
      future: getAllFile(Common().sDCardDir),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Expanded(
              child: Center(
            child: CircularProgressIndicator(),
          ));
        } else {
          allFiles.addAll(snapshot.data);
          type2Files[currentType].addAll(allFiles);
          filterTypeFiles();
          return fileList();
        }
      },
    );
  }

  fileList() {
    return Expanded(
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: type2Files[currentType].length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return _buildFileItem(type2Files[currentType][index]);
            }));
  }

  Widget _buildFileItem(FileSystemEntity file) {
    String modifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN')
        .format(file.statSync().modified.toLocal());
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 0.5, color: Color(Constants.COLOR_DIVIDER))),
        ),
        child: ListTile(
            leading: Common().selectIcon(file.path, true),
            title: Text(file.path.substring(file.parent.path.length + 1)),
            subtitle: Text(
                '$modifiedTime  ${Common().getFileSize(file.statSync().size)}',
                style: TextStyle(fontSize: 12.0)),
            trailing: Checkbox(
              value: selectedFiles.contains(file.path),
              onChanged: (bool value) {
                setState(() {
                  if (value) {
                    selectedFiles.add(file.path);
                    filesSize += file.statSync().size;
                  } else {
                    selectedFiles.remove(file.path);
                    filesSize -= file.statSync().size;
                  }
                });
              },
            )),
      ),
    );
  }

  notifyCurrentType(String type) {
    print(type);
    if (type == currentType) {
      return;
    }
    setState(() {
      currentType = type;
    });
  }

  fileTypeGridView() {
    List<Widget> children = [];
    type2Icon.forEach((type, widget) {
      children.add(iconTextBtn(widget, type, notifyCurrentType));
    });
    return Wrap(
      spacing: 8.0, // 主轴(水平)方向间距
      alignment: WrapAlignment.center, //沿主轴方向居中
      children: children,
    );
  }

  iconTextBtn(Widget icon, String type, Function call) {
    return InkWell(
        onTap: () => call(type),
        child: Chip(
          avatar: CircleAvatar(
            child: Padding(
              child: icon,
              padding: EdgeInsets.all(4),
            ),
            backgroundColor: Color.fromARGB(0x00, 0xff, 0xff, 0xff),
          ),
          backgroundColor: Color.fromARGB(0x66, 0xAA, 0xFF, 0xFF),
          label: Text(type),
        ));
  }
}
