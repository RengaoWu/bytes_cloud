import 'dart:io';

import 'package:bytes_cloud/core/handler/CloudFileHandler.dart';
import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/http/http.dart';
import 'package:bytes_cloud/pages/widgets/CloudPhotoFragment.dart';
import 'package:bytes_cloud/pages/widgets/PopWindows.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/SPWrapper.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  int _sortType = 0; // 0 by time, 1 by a-z
  int _showFlag = 0;
  int get showFlag => _showFlag;

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
    currentFiles = CloudFileManager.instance().listFiles(pid, type: _sortType);
  }

  bool _outFolderAndRefresh() {
    if (path.length == 1) return true;
    setState(() {
      path.removeLast();
      currentFiles = CloudFileManager.instance()
          .listFiles(path.last.id, justFolder: false, type: _sortType);
    });
    return false;
  }

  // public
  refreshList() {
    setState(() {
      currentFiles = CloudFileManager.instance()
          .listFiles(path.last.id, justFolder: false, type: _sortType);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    GlobalKey key1 = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.widgets, key: key1),
          onPressed: () {
            PopupWindow.showPopWindow(
                context, '', key1, PopDirection.bottom, typeSelectorView(), 16);
          },
        ),
        actions: getActionsByType(),
      ),
      body: selectShowUI(_showFlag),
    );
  }

  // 分类视图，过滤掉一些action
  getActionsByType() {
    GlobalKey key2 = GlobalKey();
    List<Widget> actions = <Widget>[
      Builder(
          builder: (context) => IconButton(
              icon: Icon(Icons.add), onPressed: () => newFolder(context))),
      IconButton(
        icon: Icon(Icons.transform),
        onPressed: () {},
      ),
      IconButton(
        key: key2,
        enableFeedback: false,
        icon: Icon(Icons.sort),
        onPressed: () async {
          int type = await sortByTypeSelectorView(key2);
          print('sort type = $type');
          if (type != null && type != _sortType) {
            _sortType = type;
            refreshList();
          }
          ;
        },
      )
    ];
    if (_showFlag != 0) {
      actions.removeAt(2);
      actions.removeAt(0);
    }
    return actions;
  }

  newFolder(BuildContext context, {Function finishedCall}) async {
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

  /// showFlag
  selectShowUI(int showFlag) {
    if (showFlag == 0) {
      return WillPopScope(
        child: cloudListView(),
        onWillPop: () async => _outFolderAndRefresh(),
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
            onPressed: () async =>
                RemoteRoutePlugin(this).showBottomSheet(entity),
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
                      RemoteRoutePlugin(this).downloadAction(entity);
                    }
                  }
                },
                trailing: trailing);
          }
          // 添加长按监听
          var inkItem = Builder(builder: (BuildContext context) {
            return InkWell(
              child: item,
              onLongPress: () async =>
                  await RemoteRoutePlugin(this).showBottomSheet(entity),
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
                UI.iconTxtBtn(Constants.FOLDER, "列表",
                    () => setState(() => _showFlag = 0)),
                UI.iconTxtBtn(
                    Constants.PHOTO, "图片", () => setState(() => _showFlag = 1)),
                UI.iconTxtBtn(Constants.VIDEO, "视频", null),
                UI.iconTxtBtn(Constants.MUSIC, "音乐", null),
                UI.iconTxtBtn(Constants.DOC, "文档", null),
                UI.iconTxtBtn(Constants.COMPRESSFILE, "压缩包", null),
              ],
            )),
      );

  Future<int> sortByTypeSelectorView(GlobalKey key) async {
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

// 对文件或者文件夹对操作独立出来
class RemoteRoutePlugin {
  RemoteRouteState state;

  RemoteRoutePlugin(this.state) {
    context = state.context;
  }
  BuildContext context;

  showBottomSheet(CloudFileEntity entity) async {
    Widget content = Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Row(
          children: <Widget>[
            Expanded(
                child: UI.iconTxtBtn(Constants.DOWNLOADED, '下载', () {
              Navigator.pop(context);
              downloadAction(entity);
            }, fontWeight: FontWeight.normal)),
            Expanded(
                child: UI.iconTxtBtn(
                    Constants.SHARE2, '分享', () => shareAction(entity),
                    fontWeight: FontWeight.normal)),
            Expanded(
                child: UI.iconTxtBtn(Constants.MOVE, '移动', null,
                    fontWeight: FontWeight.normal)),
            Expanded(
                child: UI.iconTxtBtn(Constants.DELETE, '删除', null,
                    fontWeight: FontWeight.normal)),
            Expanded(
                child: UI.iconTxtBtn(
                    Constants.MODIFY, '重命名', () => reNameAction(entity),
                    fontWeight: FontWeight.normal)),
            Expanded(
                child: UI.iconTxtBtn(Constants.MORE, '详情', null,
                    fontWeight: FontWeight.normal)),
          ],
        ));
    UI.bottomSheet(
        context: context, content: content, height: 100, radius: 8, padding: 8);
  }

  shareAction(CloudFileEntity entity) async {
    Navigator.pop(context);
    UI.showContentDialog(context, '分享文件: ${entity.fileName}',
        QrImage(data: getDownloadUrl(entity.id)),
        left: '保存到本地', leftCall: () {}, right: '分享', rightCall: () {});
    // QrImage
  }

  downloadAction(CloudFileEntity entity) async {
    if (entity.isFolder()) {
      UI.showSnackBar(context, Text('文件夹暂时不支持批量下载'));
      return;
    }
    File localFile = File(FileUtil.getDownloadFilePath(entity));
    if (SPUtil.getBool(SPUtil.downloadedKey(entity.id), false) &&
        localFile.existsSync()) {
      UI.openFile(context, localFile);
      return;
    }
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
    String input = await UI.showInputDialog(context, '重命名');
    if (input == null || input.trim() == '') return;
    String newName = input + FileUtil.ext(entity.fileName);
    bool success =
        await CloudFileHandle.renameFile(entity.id, newName); // 告诉Svr
    if (success) {
      state.refreshList();
      // refreshList();
    }
  }
}
