import 'dart:convert';
import 'dart:io';

import 'package:bytes_cloud/common.dart';
import 'package:bytes_cloud/test/ch8.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../EventBusUtil.dart';

class DocPushRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DocPushRouteState();
  }
}

class DocPushRouteState extends State<DocPushRoute> {
  MethodChannel _channel = MethodChannel('openFileChannel');
  List<String> selectedFiles = [];
  int filesSize = 0;
  BuildContext buildContext;

  Future<String> getAllFile(String path) async {
    final Map<String, dynamic> args = <String, dynamic>{'path': path};
    return await _channel.invokeMethod('getAllFiles', args);
  }

  List<FileSystemEntity> allFiles = new List<FileSystemEntity>();

  String currentType = '全部文档';
  Map<String, Widget> type2Icon = {
    '全部文档': Text('A'),
    'DOC': Image.asset(Constants.DOC),
    'XLS': Image.asset(Constants.EXCEL),
    'PPT': Image.asset(Constants.PPT),
    'PDF': Image.asset(Constants.PSD),
    'TXT': Image.asset(Constants.TXT)
  };

  Map<String, List<FileSystemEntity>> type2Files = {
    '全部文档': [],
    'DOC': [],
    'XLS': [],
    'PPT': [],
    'PDF': [],
    'TXT': [],
  };

  @override
  void initState() {
    super.initState();
    buildContext = context;
  }

  call(BuildContext context) {
    String content = '';
    if (selectedFiles.length == 0) {
      content = '没有选择任何文件';
    } else {
      content =
          '开始上传，总共${selectedFiles.length}个文件，共${Common().getFileSize(filesSize)}';
    }
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(content)));
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
                  call(context);
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
          List files = json.decode(snapshot.data);
          files.forEach((path) => allFiles.add(File(path)));
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
            leading: Image.asset(Common().selectIcon(p.extension(file.path))),
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

  filterTypeFiles() {
    allFiles.forEach((file) {
      if (file.path.endsWith('.doc') || file.path.endsWith('.docx')) {
        type2Files['DOC'].add(file);
      } else if (file.path.endsWith('.xls') || file.path.endsWith('.xlsx')) {
        type2Files['XLS'].add(file);
      } else if (file.path.endsWith('.ppt') || file.path.endsWith('.pptx')) {
        type2Files['PPT'].add(file);
      } else if (file.path.endsWith('.pdf')) {
        type2Files['PDF'].add(file);
      } else if (file.path.endsWith('.txt')) {
        type2Files['TXT'].add(file);
      }
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
    return UnconstrainedBox(
      child: Chip(
        avatar: CircleAvatar(
          child: InkWell(
              onTap: () => call(type),
              child: Padding(
                child: icon,
                padding: EdgeInsets.all(4),
              )),
          backgroundColor: Color.fromARGB(0x00, 0xff, 0xff, 0xff),
        ),
        backgroundColor: Color.fromARGB(0x66, 0xAA, 0xFF, 0xFF),
        label: InkWell(
          child: Text(type),
          onTap: () => call(type),
        ),
      ),
    );
  }
}
