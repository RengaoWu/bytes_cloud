import 'dart:convert';
import 'dart:io';

import 'package:bytes_cloud/core/handler/CloudFileHandler.dart';
import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/pages/widgets/CloudPhotoFragment.dart';
import 'package:bytes_cloud/pages/widgets/PopWindows.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:dio/dio.dart';
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
  int sortType = 0; // 0 by time, 1 by a-z
  int _showFlag = 0;

  @override
  void initState() {
    super.initState();
    enterFolder(CloudFileManager.instance().rootId);
  }

  enterFolderAndRefresh(int pid) => setState(() {
        enterFolder(pid);
      });

  enterFolder(int pid) {
    path.add(CloudFileManager.instance().getEntityById(pid));
    currentFiles = CloudFileManager.instance().listFiles(pid, type: sortType);
  }

  bool outFolderAndRefresh() {
    if (path.length == 1) return true;
    setState(() {
      path.removeLast();
      currentFiles = CloudFileManager.instance()
          .listFiles(path.last.id, justFolder: false, type: sortType);
    });
    return false;
  }

  refreshList() {
    setState(() {
      currentFiles = CloudFileManager.instance()
          .listFiles(path.last.id, justFolder: false, type: sortType);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    GlobalKey key1 = GlobalKey();
    GlobalKey key2 = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.widgets, key: key1),
          onPressed: () {
            PopupWindow.showPopWindow(
                context, '', key1, PopDirection.bottom, typeSelectorView(), 16);
          },
        ),
        actions: <Widget>[
          Builder(
              builder: (context) => IconButton(
                  icon: Icon(Icons.add), onPressed: () => newFolder(context))),
          IconButton(
            icon: Icon(Icons.transform),
            onPressed: () {},
          ),
          IconButton(
            key: key2,
            icon: Icon(Icons.sort),
            onPressed: () async {
              int type = await sortByTypeSelectorView(key2);
              print('sort type = $type');
              if (type != null && type != sortType) {
                sortType = type;
                refreshList();
              }
              ;
            },
          )
        ],
      ),
      body: selectShowUI(_showFlag),
    );
  }

  /// showFlag
  selectShowUI(int showFlag) {
    if (showFlag == 0) {
      return WillPopScope(
        child: cloudListView(),
        onWillPop: () async => outFolderAndRefresh(),
      );
    } else if (showFlag == 1) {
      return CloudPhotoFragment();
    }
  }

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
            onPressed: () async => showBottomSheet(entity),
          );
          if (entity.isFolder()) {
            item = UI.buildCloudFolderItem(
                file: entity,
                childrenCount:
                    CloudFileManager.instance().childrenCount(entity.id),
                onTap: () {
                  enterFolderAndRefresh(entity.id);
                },
                trailing: trailing);
          } else {
            return UI.buildCloudFileItem(
                file: entity,
                onTap: (_) async => downloadAction(entity),
                trailing: trailing);
          }
          // 添加长按监听
          var inkItem = Builder(builder: (BuildContext context) {
            return InkWell(
              child: item,
              onLongPress: () async => await showBottomSheet(entity),
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
        await CloudFileHandle.reflashCloudFileList(
            failedCall: () {}, successCall: () => (_) => refreshList());
      },
    );
  }

  showBottomSheet(CloudFileEntity entity) async {
    Widget content = Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Row(
          children: <Widget>[
            Expanded(
                child: UI.iconTxtBtn(Constants.DOWNLOADED, '下载', null,
                    fontWeight: FontWeight.normal)),
            Expanded(
                child: UI.iconTxtBtn(Constants.SHARE2, '分享', null,
                    fontWeight: FontWeight.normal)),
            Expanded(
                child: UI.iconTxtBtn(Constants.MOVE, '移动', null,
                    fontWeight: FontWeight.normal)),
            Expanded(
                child: UI.iconTxtBtn(Constants.DELETE, '删除', null,
                    fontWeight: FontWeight.normal)),
            Expanded(
                child: UI.iconTxtBtn(Constants.MODIFY, '重命名', null,
                    fontWeight: FontWeight.normal)),
            Expanded(
                child: UI.iconTxtBtn(Constants.MORE, '详情', null,
                    fontWeight: FontWeight.normal)),
          ],
        ));
    UI.bottomSheet(
        context: context, content: content, height: 100, radius: 8, padding: 8);
  }

  downloadAction(CloudFileEntity entity) async {
    UI.showSnackBar(context, Text('开始下载 ${entity.fileName}'));
    await CloudFileHandle.downloadOneFile(entity, CancelToken());
    UI.showSnackBar(
        context,
        InkWell(
          child: Text('${entity.fileName} 下载完成'),
          onTap: () =>
              UI.openFile(context, File(FileUtil.getDownloadFilePath(entity))),
        ),
        duration: Duration(seconds: 3));
  }

  reNameAction(CloudFileEntity entity) async {
    //UI.bottomSheet(context: null, content: null)
    String ext = FileUtil.ext(entity.fileName);
    String newName = await UI.showInputDialog(context, '重命名');
    if (newName == null || newName.trim() == '') return;
    await CloudFileManager.instance().renameFile(entity.id, newName + ext);
    setState(() {});
  }

  newFolder(BuildContext context) async {
    String folderName = await UI.showInputDialog(context, "创建文件夹");
    if (folderName == null) return;
    if (folderName.trim() == '') {
      UI.showSnackBar(context, Text('文件名为空'));
      return;
    }
    await CloudFileHandle.newFolder(path.last.id, folderName.trim(),
        successCall: (_) => refreshList(),
        failedCall: (Map<String, dynamic> rsp) {
          UI.showSnackBar(context, rsp['message']);
        });
  }

  typeSelectorView() => Container(
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
                UI.iconTxtBtn(
                    Constants.PHOTO, "图片", () => setState(() => _showFlag = 1)),
                UI.iconTxtBtn(Constants.VIDEO, "视频", null),
                UI.iconTxtBtn(Constants.MUSIC, "音乐", null),
                UI.iconTxtBtn(Constants.DOC, "文档", null),
                UI.iconTxtBtn(Constants.COMPRESSFILE, "压缩包", null),
                UI.iconTxtBtn(Constants.UNKNOW, "其他", () => {print("")}),
              ],
            )),
      );

  Future<int> sortByTypeSelectorView(GlobalKey key) async {
    Text sortByTime;
    Text sortByName;
    if (sortType == 0) {
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
                  onPressed: () => Navigator.pop(context, 0),
                ),
                FlatButton(
                  child: sortByName,
                  onPressed: () => Navigator.pop(context, 1),
                ),
              ],
            )),
        0);
  }

  @override
  bool get wantKeepAlive => true;
}
