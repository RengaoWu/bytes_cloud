import 'dart:io';

import 'package:bytes_cloud/common.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileIoslateMethods.dart';
import 'package:bytes_cloud/utils/FileTypeUtils.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../CacheManager.dart';

class TypeFileSelectorPage extends StatefulWidget {
  final String argType;
  TypeFileSelectorPage(this.argType);
  @override
  State<StatefulWidget> createState() {
    return TypeFileSelectorPageState(argType);
  }
}

class TypeFileSelectorPageState extends State<TypeFileSelectorPage> {
  String argType;
  List<String> selectedFiles = [];
  int filesSize = 0;
  String currentType = Constants.TYPE_ALL;
  List<FileSystemEntity> allFiles = [];
  Map<String, Widget> type2Icon = {};
  Map<String, String> extensionName2Type = {};
  Map<String, List<FileSystemEntity>> type2Files = {};
  TypeFileSelectorPageState(this.argType);
  bool isReady = false;

  // 内存缓存，
  Future<List<FileSystemEntity>> getAllFile(List<String> paths) async {
    List<FileSystemEntity> res = [];
    // 缓存中有
    if (cache[argType] != null) {
      cache[argType].forEach((f) {
        FileSystemEntity file = File(f);
        if (file.existsSync()) {
          // check
          res.add(file);
        }
      });
      return res;
    }
    Map<String, dynamic> args = {
      'keys': extensionName2Type.keys.toList(),
      'roots': paths,
      'isExt': true,
    };
    res = (await compute(wapperGetAllFiles, args));
    cache[argType] = [];
    res.forEach((f) {
      cache[argType].add(f.path);
    });
    return res;
  }

  // map操作
  mapTypeFiles() {
    allFiles.forEach((file) {
      String extension = file.path.substring(file.path.lastIndexOf('.'));
      if (extension != null && extensionName2Type.keys.contains(extension)) {
        type2Files[extensionName2Type[extension]].add(file);
      }
    });
  }

  initData() {
    FileTypeUtils.convert(argType, type2Icon, extensionName2Type);
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
                  UI.pushToCloud(context, selectedFiles.length, filesSize);
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          fileTypeGridView(),
          isReady ? fileList() : loadFilesFuture(),
          Padding(
              padding: EdgeInsets.all(4),
              child: Center(
                child: Text(
                    '总共 ${selectedFiles.length} 项，总共 ${Common().getFileSize(filesSize)}'),
              ))
          //Expanded(child: FileSelectorFragment()),
        ],
      ),
    );
  }

  loadFilesFuture() {
    return FutureBuilder(
      future: getAllFile(FileTypeUtils.getPaths(argType)),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Expanded(
              child: Center(
            child: CircularProgressIndicator(),
          ));
        } else {
          return handleLoadFiles(snapshot.data);
        }
      },
    );
  }

  handleLoadFiles(List<FileSystemEntity> list) {
    allFiles.addAll(list);
    sortFiles();
    type2Files[currentType].addAll(allFiles);
    mapTypeFiles();
    isReady = true;
    return fileList();
  }

  // 时间降序排列
  sortFiles() {
    allFiles
        .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
  }

  fileList() {
    return Expanded(child: Scrollbar(child: selectShowStyle()));
  }

  selectShowStyle() {
    if (argType == FileTypeUtils.ARG_VIDEO) {
      return mediaGridView();
    } else {
      return customerListView();
    }
  }

  customerListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: type2Files[currentType].length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return customerListViewItem(context, index);
        });
  }

  customerListViewItem(BuildContext context, int index) {
    File file = type2Files[currentType][index];
    return UI.buildFileItem(
        file: file,
        isCheck: selectedFiles.contains(file.path),
        onChanged: onChange,
        onTap: onTap);
  }

  // image or video use this item
  mediaGridView() {
    return StaggeredGridView.countBuilder(
      itemCount: type2Files[currentType].length,
      itemBuilder: (BuildContext context, int index) {
        return inkwellItemCard(type2Files[currentType][index]);
      },
      crossAxisCount: 4,
      staggeredTileBuilder: (index) => StaggeredTile.fit(2),
    );
  }

  inkwellItemCard(FileSystemEntity file) {
    return InkWell(
      child: itemCard(file),
      onTap: () => UI.openFile(context, file, null),
    );
  }

  itemCard(FileSystemEntity file) {
    return Card(
      child: Stack(
        children: <Widget>[
          Common().getThumbFutureBuilder(file.path),
          Text(
            FileUtil.getFileName(file.path),
            style: TextStyle(fontSize: 10),
          )
        ],
      ),
    );
  }

  onChange(bool value, FileSystemEntity file) {
    setState(() {
      if (value) {
        selectedFiles.add(file.path);
        filesSize += file.statSync().size;
      } else {
        selectedFiles.remove(file.path);
        filesSize -= file.statSync().size;
      }
    });
  }

  onTap(FileSystemEntity file) {
    UI.openFile(context, file, {'files': allFiles});
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

  // 类型筛选Grid
  fileTypeGridView() {
    if (!FileTypeUtils.showType(argType)) {
      return Container();
    }
    List<Widget> children = [];
    type2Icon.forEach((type, widget) {
      children.add(UI.iconTextBtn(widget, type, notifyCurrentType));
    });
    return Wrap(
      spacing: 8.0, // 主轴(水平)方向间距
      alignment: WrapAlignment.center, //沿主轴方向居中
      children: children,
    );
  }
}
