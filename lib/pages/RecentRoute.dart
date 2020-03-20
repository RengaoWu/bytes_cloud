import 'dart:io';
import 'dart:ui';

import 'package:bytes_cloud/core/common.dart';
import 'package:bytes_cloud/core/manager/CloudFileLogic.dart';
import 'package:bytes_cloud/entity/DBManager.dart';
import 'package:bytes_cloud/entity/RecentFileEntity.dart';
import 'package:bytes_cloud/pages/plugins/ScanPage.dart';
import 'package:bytes_cloud/pages/selectors/SearchFilePage.dart';
import 'package:bytes_cloud/pages/selectors/SysFileSelectorPage.dart';
import 'package:bytes_cloud/pages/widgets/PopWindows.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/IoslateMethods.dart';
import 'package:bytes_cloud/utils/OtherUtil.dart';
import 'package:bytes_cloud/utils/SPWrapper.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RecentRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RecentRouteState();
  }
}

class RecentRouteState extends State<RecentRoute>
    with AutomaticKeepAliveClientMixin {
  ScrollController _controller = ScrollController(keepScrollOffset: true);
  Future scan() async => UI.newPage(context, ScanPage());
  Widget _recentFileListView;
  List<MapEntry<int, List<RecentFileEntity>>> _sourceListData;
  bool hasNew = false; // 第一次打开需要加载列表
  bool showToTopBtn = false;

  @override
  void initState() {
    super.initState();
    //监听滚动事件，打印滚动位置
    _controller.addListener(() {
      if (_controller.offset < 1000 && showToTopBtn) {
        setState(() {
          showToTopBtn = false;
          hasNew = false;
        });
      } else if (_controller.offset >= 1000 && showToTopBtn == false) {
        setState(() {
          showToTopBtn = true;
          hasNew = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.search),
            onPressed: () => UI.newPage(context,
                SearchFilePage({'key': '', 'roots': Common().recentDir}))),
        centerTitle: true,
        title: boldText(
          '最近',
        ),
        actions: <Widget>[
          Container(
            width: 40,
            padding: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(Icons.crop_free),
              onPressed: scan,
            ),
          ),
        ],
      ),
      floatingActionButton: showToTopBtn
          ? FloatingActionButton(
              child: Icon(Icons.arrow_upward),
              onPressed: () {
                _controller.animateTo(0,
                    duration: Duration(milliseconds: 500), curve: Curves.ease);
              })
          : null,
      body: Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: recentFilesListViewFuture(),
      ),
    );
  }

  // 最近的文件：来源：微信、QQ、下载管理器、相机、QQ邮箱、浏览器、百度网盘、音乐、
  recentFilesListViewFuture() {
    print("hasNew $hasNew");
    if (hasNew) _recentFileListView = recentListView();
    if (_recentFileListView != null) {
      print('use old');
      return _recentFileListView;
    }

    return FutureBuilder<bool>(
      future: hasNewRecentFilesFromFileSystem(), // 如果有新数据，直接更新到_SourceListData
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: SizedBox(
                  height: 48, width: 48, child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          _recentFileListView = recentListView();
          return _recentFileListView;
        }
        return Text(snapshot.error.toString());
      },
    );
  }

  updateListData() async {
    // kv : <groupMd5, entity> and check file exist
    var recentList = await getRecentFilesFromDB();
    Map<int, List<RecentFileEntity>> map = {};
    recentList.forEach((f) {
      File file = File(f.path);
      if (file.existsSync()) {
        int date = f.groupMd5;
        if (map.containsKey(date)) {
          map[date].add(f);
        } else {
          map[date] = [f];
        }
      } else {
        DBManager.instance.delete(RecentFileEntity.tableName, {'path': f.path});
      }
    });
    // return list view
    _sourceListData = map.entries.toList();
  }

  Widget recentListView() {
    ListView listView = ListView.builder(
      controller: _controller,
      itemCount: _sourceListData.length + 1,
      key: PageStorageKey('RecentRoute'),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return headerView();
        }
        return contentItemView(_sourceListData[index - 1].value);
      },
    );

    hasNew = false;
    return RefreshIndicator(
      child: listView,
      onRefresh: () async {
        await hasNewRecentFilesFromFileSystem().then((v) {
          if (v) {
            setState(() {
              hasNew = true;
            });
          }
        });
      },
    );
  }

  // 查询是否有新文件，如果有添加到数据库
  Future<bool> hasNewRecentFilesFromFileSystem() async {
    // 增量查询
    List<FileSystemEntity> recentFiles = await compute(wapperGetAllFiles, {
      "keys": Common().recentFileExt(),
      "roots": Common().recentDir,
      "isExt": true,
      'fromTime': SPUtil.getInt("lastGetRecentFileTime", 0)
    });
    // 更新时间戳
    var newTimeStamp = 0;
    if (recentFiles.length == 0) {
      newTimeStamp = DateTime.now().millisecondsSinceEpoch;
    } else {
      newTimeStamp = recentFiles[0].statSync().modified.millisecondsSinceEpoch;
    }
    SPUtil.setInt("lastGetRecentFileTime", newTimeStamp);
    // 存入数据库
    print("增量查询最近文件, 新文件长度:${recentFiles.length}");
    bool hasNewRecentFile = false;
    recentFiles.forEach((f) {
      if (f.statSync().size > 1024) {
        DBManager.instance.insert(RecentFileEntity.tableName,
            RecentFileEntity.forSystemFileEntity(f));
        hasNewRecentFile = true;
      }
    });
    if (hasNewRecentFile || _sourceListData == null) {
      await updateListData();
      print('更新数据');
    }
    return hasNewRecentFile;
  }

  Future<List<RecentFileEntity>> getRecentFilesFromDB() async {
    // 全量数据库查询
    List<Map> maps = await DBManager.instance
        .queryAll(RecentFileEntity.tableName, 'modifyTime desc'); // for db
    List<RecentFileEntity> result = [];
    // 转化类型
    if (maps != null && maps.length != 0) {
      maps.forEach((f) {
        result.add(RecentFileEntity.fromMap(f));
      });
    }
    print(result.length);
    return result;
  }

  headerView() {
    return Column(
      children: <Widget>[
        UI.leftTitle('快捷访问'),
        headerGridView(),
        UI.divider(width: 1)
      ],
    );
  }

  static const int PIC_MAX_SHOW_LENGTH = 4;
  contentItemView(List<RecentFileEntity> group) {
    return Card(
        elevation: 2,
        child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                itemTitleView(group),
                itemInnerView(group),
                itemTailView(group[0]),
              ],
            )));
  }

  itemTailView(RecentFileEntity file) {
    return Row(children: <Widget>[
      Text(
        convertTimeToString(
            DateTime.fromMillisecondsSinceEpoch(file.modifyTime)),
        style: TextStyle(fontSize: 12, color: Colors.grey),
      )
    ]);
  }

  itemTitleView(List<RecentFileEntity> files) {
    String source = RecentFileEntity.fileFrom(files[0].path);
    String sourceIcon = RecentFileEntity.fileIcon(source);
    String type = RecentFileEntity.fileType(files[0].path);
    GlobalKey key = GlobalKey();
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(4),
          child: Image.asset(
            sourceIcon,
            width: 16,
            height: 16,
          ),
        ),
        Expanded(
            child: Text(
          '来自${source}的${type}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        )),
        InkWell(
          child: Icon(
            Icons.more_vert,
            key: key,
            size: 18,
          ),
          onTap: () {
            showMoreWindow(key, files);
          },
        ),
      ],
    );
  }

  showMoreWindow(GlobalKey key, List<RecentFileEntity> entities) {
    PopupWindow.showPopWindow(
      context,
      '',
      key,
      PopDirection.left,
      Card(
          elevation: 4,
          child: Column(
            children: <Widget>[
              FlatButton(
                child: Text("上传到云"),
                onPressed: () {
                  ///
                  CloudFileHandle.uploadOneFile(0, entities[0].path);
                },
              ),
              FlatButton(
                child: Text("分享"),
                onPressed: () {},
              ),
            ],
          )),
    );
  }

  double itemInnerViewPhotoSize = (UI.DISPLAY_WIDTH - 40) / 2;
  itemInnerView(List<RecentFileEntity> group) {
    if (FileUtil.isVideo(group[0].path) || FileUtil.isImage(group[0].path)) {
      return itemInnerImageView(group);
    } else {
      return itemInnerFileView(group);
    }
  }

  itemInnerImageView(List<RecentFileEntity> group) {
    List<RecentFileEntity> showData;
    if (group.length >= PIC_MAX_SHOW_LENGTH) {
      showData = group.sublist(0, PIC_MAX_SHOW_LENGTH);
    } else {
      showData = group;
    }
    int i = 0;
    var widgets = showData.map((f) {
      i++;
      if (i == PIC_MAX_SHOW_LENGTH) {
        return SizedBox(
          width: itemInnerViewPhotoSize,
          height: itemInnerViewPhotoSize,
          child: Stack(
            children: <Widget>[
              UI.selectPreview(f.path, itemInnerViewPhotoSize),
              InkWell(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  width: itemInnerViewPhotoSize,
                  height: itemInnerViewPhotoSize,
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 84,
                  ),
                ),
                onTap: () => openFile(f, group),
              )
            ],
          ),
        );
      }
      return InkWell(
        child: Hero(
          child: UI.selectPreview(f.path, itemInnerViewPhotoSize),
          tag: f.path,
        ),
        onTap: () {
          openFile(f, group);
        },
      );
    }).toList();
    return Container(
        padding: EdgeInsets.only(top: 4, bottom: 4),
        child: Wrap(
          children: widgets,
        ));
  }

  itemInnerFileView(List<RecentFileEntity> group) {
    var widgets = group.map((f) {
      return ListTile(
        leading: UI.selectIcon(f.path, false),
        title: Text(
          FileUtil.getFileName(f.path),
        ),
        subtitle: Text(
          FileUtil.getFileSize(
            File(f.path).statSync().size,
          ),
          style: TextStyle(fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_right),
        onTap: () {
          openFile(f, group);
        },
      );
    }).toList();
    return Column(
      children: widgets,
    );
  }

  openFile(RecentFileEntity f, List<RecentFileEntity> group) {
    List<FileSystemEntity> sysFiles = group.map((entity) {
      return File(entity.path);
    }).toList();
    UI.openFile(context, File(f.path), files: sysFiles);
  }

  callDownloadSelector() => UI.newPage(context,
      SysFileSelectorPage({'root': Common().downloadDir, 'rootName': '下载'}));
  callWxSelector() => UI.newPage(context,
      SysFileSelectorPage({'root': Common().sWxDirDownload, 'rootName': '微信'}));
  callQQSelector() => UI.newPage(context,
      SysFileSelectorPage({'root': Common().TencentRoot, 'rootName': 'QQ'}));
  callScreamShotSelector() => UI.newPage(context,
      SysFileSelectorPage({'root': Common().screamShot, 'rootName': '截图'}));
  callCameraSelector() => UI.newPage(context,
      SysFileSelectorPage({'root': Common().camera, 'rootName': '相机'}));
  headerGridView() => GridView.count(
        shrinkWrap: true,
        crossAxisCount: 5,
        children: <Widget>[
          // 快捷访问
          UI.iconTxtBtn(Constants.WECHAT, '微信', callWxSelector),
          UI.iconTxtBtn(Constants.QQ, 'QQ', callQQSelector),
          UI.iconTxtBtn(Constants.DOWNLOADED, '下载', callDownloadSelector),
          UI.iconTxtBtn(Constants.SCREAMSHOT, '截图', callScreamShotSelector),
          UI.iconTxtBtn(Constants.CAMERA, '相机', callCameraSelector),
        ],
      );

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    print('recent route dispose');
  }

  @override
  void deactivate() {
    super.deactivate();
    print('recent route deactivate');
  }
}
