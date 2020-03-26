import 'dart:io';

import 'package:bytes_cloud/core/handler/CloudFileHandler.dart';
import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/pages/content/remote/CloudPhotoFragment.dart';
import 'package:bytes_cloud/pages/content/remote/RemoteRouteHelper.dart';
import 'package:bytes_cloud/pages/widgets/PopWindows.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RemoteRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RemoteRouteState();
  }
}

class RemoteRouteState extends State<RemoteRoute>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<CloudFileEntity> currentFiles = [];
  List<CloudFileEntity> path = []; // 路径
  Function _sortType = CloudFileEntity.sortByTime; // 0 by time, 1 by a-z
  int _clzType = 0; // 0 列表，1 图片，

  @override
  void initState() {
    super.initState();
    _enterFolder(CloudFileManager.instance().rootId);
  }

  _enterFolderAndRefresh(int pid) => setState(() {
        _enterFolder(pid);
      });

  _enterFolder(int pid) {
    path.add(CloudFileManager.instance().getEntityById(pid));
    currentFiles = CloudFileManager.instance().listFiles(
      pid,
    );
  }

  bool _outFolderAndRefresh() {
    if (path.length == 1) return true;
    setState(() {
      path.removeLast();
      currentFiles = CloudFileManager.instance()
          .listFiles(path.last.id, justFolder: false, sortFunc: _sortType);
    });
    return false;
  }

  _refreshList() {
    setState(() {
      currentFiles = CloudFileManager.instance()
          .listFiles(path.last.id, justFolder: false, sortFunc: _sortType);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    GlobalKey key1 = GlobalKey();

    Widget selectShowUI(int showFlag) {
      if (showFlag == 0) {
        return WillPopScope(
          child: cloudListView(),
          onWillPop: () async => _outFolderAndRefresh(),
        );
      } else if (showFlag == 1) {
        return CloudPhotoFragment();
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.widgets, key: key1),
          onPressed: () => PopupWindow.showPopWindow(
              context, '', key1, PopDirection.bottom, _typeSelectorView(), 16),
        ),
        actions: _getActionsByType(),
      ),
      body: selectShowUI(_clzType),
    );
  }

  // 不同的视图，展示的actions不一样
  _getActionsByType() {
    GlobalKey key2 = GlobalKey();
    Widget newFolderAction = Builder(
        builder: (context) => IconButton(
            icon: Icon(Icons.add), onPressed: () => _newFolder(context)));
    Widget transformAction = IconButton(
      icon: Icon(Icons.transform),
      onPressed: () {},
    );
    Widget sortActionForm = IconButton(
      key: key2,
      enableFeedback: false,
      icon: Icon(Icons.sort),
      onPressed: () async {
        Function type = await _sortByTypeSelectorView(key2);
        print('sort type = $type');
        if (type != null && type != _sortType) {
          _sortType = type;
          _refreshList();
        }
        ;
      },
    );
    List<Widget> actions = <Widget>[];
    if (_clzType == RemoteRouteHelper.SHOW_TYPE_FILE) {
      actions.add(newFolderAction);
      actions.add(transformAction);
      actions.add(sortActionForm);
    } else {
      actions.add(transformAction);
    }
    return actions;
  }

  _newFolder(BuildContext context, {Function finishedCall}) async {
    String folderName = await UI.showInputDialog(context, "创建文件夹");
    if (folderName == null) return;
    if (folderName.trim() == '') {
      UI.showSnackBar(context, Text('文件名为空'));
      return;
    }
    bool success = await CloudFileManager.instance()
        .newFolder(path.last.id, folderName.trim());
    if (success)
      _refreshList();
    else
      UI.showSnackBar(context, Text('创建失败'));
  }

  //
  cloudListView() {
    var listView = ListView.separated(
        itemCount: currentFiles.length,
        separatorBuilder: (BuildContext context, int index) {
          return UI.divider2(left: 80, right: 32);
        },
        itemBuilder: (BuildContext context, int index) {
          CloudFileEntity entity = currentFiles[index];
          Widget item;
          Widget trailing = IconButton(
            icon: Icon(
              Icons.more_horiz,
              size: 14,
            ),
            onPressed: () async =>
                RemoteRouteHelper(context).showBottomSheet(entity),
          );
          if (entity.isFolder()) {
            item = UI.buildCloudFolderItem(
                file: entity,
                childrenCount:
                    CloudFileManager.instance().childrenCount(entity.id),
                onTap: () {
                  _enterFolderAndRefresh(entity.id);
                },
                trailing: trailing);
          } else {
            return UI.buildCloudFileItem(
                file: entity,
                onTap: (_) async {
                  // 如果已下载，直接打开
                  if (FileUtil.haveDownloaded(entity)) {
                    UI.openFile(
                        context, File(FileUtil.getDownloadFilePath(entity)));
                    return;
                  } else {
                    // 如果是图片直接预览
                    if (FileUtil.isImage(entity.fileName)) {
                      UI.openCloudFile(context, entity);
                    } else {
                      RemoteRouteHelper(context).downloadAction(entity);
                    }
                  }
                },
                trailing: trailing);
          }
          // 添加长按监听
          var inkItem = Builder(builder: (BuildContext context) {
            return InkWell(
              child: item,
              onLongPress: () async => await RemoteRouteHelper(context)
                  .showBottomSheet(entity, callBack: () {
                _refreshList();
              }),
            );
          });
          return Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: inkItem,
          );
        });
    return RefreshIndicator(
      child: Scrollbar(child: listView),
      onRefresh: () async {
        bool success = await CloudFileManager.instance().reflashCloudFileList();
        if (success) _refreshList();
      },
    );
  }

  _typeSelectorView() {
    modifyShowType(int newType) {
      if (newType != _clzType) {
        setState(() {
          _clzType = newType;
        });
      }
      Navigator.pop(context);
    }

    return Container(
      width: UI.DISPLAY_WIDTH,
      color: Colors.transparent,
      alignment: Alignment.center,
      height: 220,
      child: Card(
          color: Colors.white,
          child: GridView.count(
            crossAxisCount: 4,
            physics: ScrollPhysics(),
            children: <Widget>[
              UI.iconTxtBtn(Constants.FOLDER, "列表",
                  () => modifyShowType(RemoteRouteHelper.SHOW_TYPE_FILE)),
              UI.iconTxtBtn(Constants.PHOTO, "图片",
                  () => modifyShowType(RemoteRouteHelper.SHOW_TYPE_PHOTO)),
              UI.iconTxtBtn(Constants.VIDEO, "视频", null),
              UI.iconTxtBtn(Constants.MUSIC, "音乐", null),
              UI.iconTxtBtn(Constants.DOC, "文档", null),
              UI.iconTxtBtn(Constants.COMPRESSFILE, "压缩包", null),
            ],
          )),
    );
  }

  Future<Function> _sortByTypeSelectorView(GlobalKey key) async {
    Text sortByTime;
    Text sortByName;
    if (_sortType == 0) {
      sortByTime = Text(
        '时间排序',
        style: TextStyle(color: Colors.blue),
      );
      sortByName = Text('名称排序');
    } else {
      sortByName = Text(
        '名称排序',
        style: TextStyle(color: Colors.blue),
      );
      sortByTime = Text('时间排序');
    }
    return await PopupWindow.showPopWindow(
        context,
        '',
        key,
        PopDirection.bottom,
        Card(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                FlatButton(
                  child: sortByTime,
                  onPressed: () =>
                      Navigator.pop(context, CloudFileEntity.sortByTime),
                ),
                FlatButton(
                  child: sortByName,
                  onPressed: () =>
                      Navigator.pop(context, CloudFileEntity.sortByTime),
                ),
              ],
            )),
        0);
  }

  @override
  bool get wantKeepAlive => true;
}
