import 'dart:ffi';
import 'dart:io';

import 'package:bytes_cloud/common.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileIoslateMethods.dart';
import 'package:bytes_cloud/utils/FileTypeUtils.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/OtherUtil.dart';
import 'package:bytes_cloud/utils/ThumbUtil.dart';
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
        if (f.existsSync()) {
          res.add(f);
        }
      });
      return res;
    }
    res = (await compute(wapperGetAllFiles, {
      'keys': extensionName2Type.keys.toList(),
      'roots': paths,
      'isExt': true,
    }));
    cache[argType] = res;

//    // generate 缩略图
//    List<String> arg = [Common().appCache];
//    res.forEach((f) {
//      arg.add(f.path);
//    });
//    await Constants.COMMON.invokeListMethod(Constants.getThumbnails, arg);

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
    return Expanded(
        child: Scrollbar(
            child:
                Padding(padding: EdgeInsets.all(8), child: selectShowStyle())));
  }

  selectShowStyle() {
    if (argType == FileTypeUtils.ARG_VIDEO) {
      return mediaGridView(type2Files[currentType]);
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
  mediaGridView(List<FileSystemEntity> list) {
    // generate group
    List<_ViewHolder> holders = [];
    for (int i = 0; i < list.length; i++) {
      FileSystemEntity entity = list[i];
      var dataTime = entity.statSync().modified;
      if (i == 0) {
        holders.add(_ViewHolder(entity, dataTime, 1)); // group
        holders.add(_ViewHolder(entity, dataTime, 0)); //child
        continue;
      }
      var lastDataTime = list[i - 1].statSync().modified;
      if (dataTime.month == lastDataTime.month &&
          dataTime.year == lastDataTime.year) {
        holders.add(_ViewHolder(entity, dataTime, 0));
      } else {
        holders.add(_ViewHolder(entity, dataTime, 1)); // group
        holders.add(_ViewHolder(entity, dataTime, 0)); //child
      }
    }
    return StaggeredGridView.countBuilder(
      crossAxisCount: 2,
      itemCount: holders.length,
      itemBuilder: (BuildContext context, int index) {
        _ViewHolder holder = holders[index];
        return holder.type == 0
            ? inkwellItemCard(holder)
            : groupItemCard(holder);
      },
      staggeredTileBuilder: (int index) {
        _ViewHolder holder = holders[index];
        if (holder.type == 1) {
          return new StaggeredTile.count(2, 0.4);
        } else {
          return new StaggeredTile.count(1, 1);
        }
      },
    );
  }

  groupItemCard(_ViewHolder holder) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Text(
        '-----------  ${holder.dataTime.year} 年 ${holder.dataTime.month} 月 -----------',
        style: TextStyle(fontSize: 15, color: Colors.black38),
      ),
      alignment: Alignment.center,
    );
  }

  inkwellItemCard(_ViewHolder holder) {
    return InkWell(
      child: itemCard(holder),
      onTap: () => UI.openFile(context, holder.entity, null),
    );
  }

  itemCard(_ViewHolder holder) {
    String path = holder.entity.path;
    return Card(
      elevation: 4,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          getThumbWidget(path),
          Positioned(
              right: 0,
              top: 0,
              child: Checkbox(
                  value: selectedFiles.contains(path),
                  checkColor: Colors.white,
                  onChanged: (value) {
                    if (value) {
                      selectedFiles.add(path);
                      filesSize += holder.entity.statSync().size;
                    } else {
                      selectedFiles.remove(path);
                      filesSize -= holder.entity.statSync().size;
                    }
                    setState(() {});
                  })),
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              convertTimeToString(holder.dataTime),
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
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

class _ViewHolder {
  int type = 0; // type 0 is child, type 1 is group name
  FileSystemEntity entity;
  DateTime dataTime;
  _ViewHolder(this.entity, this.dataTime, this.type);
}
