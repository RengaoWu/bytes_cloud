import 'dart:collection';
import 'dart:io';

import 'package:bytes_cloud/core/common.dart';
import 'package:bytes_cloud/entity/DBManager.dart';
import 'package:bytes_cloud/entity/entitys.dart';
import 'package:bytes_cloud/pages/selectors/SysFileSelectorPage.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/IoslateMethods.dart';
import 'package:bytes_cloud/utils/OtherUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class RecentRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RecentRouteState();
  }
}

class RecentRouteState extends State<RecentRoute>
    with AutomaticKeepAliveClientMixin {
  bool isFast = false;
  HashSet<String> cacheSet = HashSet();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("RecentRouteState build");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.widgets),
            onPressed: () {
              setState(() {});
            }),
        centerTitle: true,
        title: boldText(
          '最近',
        ),
        actions: <Widget>[
          Container(
            width: 40,
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.center_focus_weak),
            //child: Image.asset(Constants.SCAN),
          ),
        ],
      ),
      body: Listener(
          onPointerMove: (PointerMoveEvent event) {
            print(event.delta.dy);
            if (event.delta.dy > 20 || event.delta.dy < -20) {
              isFast = true;
            } else {
              isFast = false;
            }
            print("isFast " + isFast.toString());
          },
          onPointerUp: (PointerUpEvent event) {
            isFast = false;
          },
          child: Scrollbar(
              child: Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: listView(),
          ))),
    );
  }

  // 最近的文件：来源：微信、QQ、下载管理器、相机、QQ邮箱、浏览器、百度网盘、音乐、
  listView() {
    return FutureBuilder<List<RecentFileEntity>>(
      future: getRecentFiles(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: SizedBox(
                  height: 48, width: 48, child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          List<RecentFileEntity> recentList = snapshot.data;
          // kv : <groupMd5, entity>
          Map<int, List<RecentFileEntity>> map = {};
          print('FutureBuilder ' + DateTime.now().toIso8601String());
          recentList.forEach((f) {
            if (f == null) {
              print('f is null');
            }
            int date = f.groupMd5;
            if (map.containsKey(date)) {
              map[date].add(f);
            } else {
              map[date] = [f];
            }
          });
          print('FutureBuilder ' + DateTime.now().toIso8601String());
          List<MapEntry<int, List<RecentFileEntity>>> list =
              map.entries.toList();
          ListView view = ListView.builder(
            shrinkWrap: true,
            itemCount: list.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return headerView();
              }
              return recentItemCard(list[index - 1].value);
            },
          );
          return view;
        }
        print(snapshot.error.toString());
        return Text(snapshot.error.toString());
      },
    );
  }

  headerView() {
    return Column(
      children: <Widget>[leftTitle('快捷访问'), gridView(), UI.divider(width: 1)],
    );
  }

  recentItemCard(List<RecentFileEntity> group) {
    return Card(
        elevation: 2,
        child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                groupTitle(group[0]),
                innerContent(group),
                groupTail(group[0]),
              ],
            )));
  }

  groupTail(RecentFileEntity file) {
    return Row(children: <Widget>[
      Text(
        convertTimeToString(
            DateTime.fromMillisecondsSinceEpoch(file.modifyTime)),
        style: TextStyle(fontSize: 12, color: Colors.grey),
      )
    ]);
  }

  groupTitle(RecentFileEntity file) {
    String source = RecentFileEntity.fileFrom(file.path);
    String type = RecentFileEntity.fileType(file.path);
    String sourceIcon;

    if (source == '微信') {
      sourceIcon = Constants.WECHAT;
    } else if (source == 'QQ') {
      sourceIcon = Constants.QQ;
    } else if (source == '文档') {
      sourceIcon = Constants.DOC;
    } else if (source == '截图') {
      sourceIcon = Constants.SCREAMSHOT;
    } else if (source == '相册') {
      sourceIcon = Constants.PHOTO;
    } else {
      sourceIcon = Constants.UNKNOW;
    }
    Widget widget = Image.asset(
      sourceIcon,
      width: 16,
      height: 16,
    );
    return Row(
      children: <Widget>[
        widget,
        Expanded(
            child: Text(
          '来自${source}的${type}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        )),
        Icon(
          Icons.more_vert,
          size: 16,
        ),
      ],
    );
  }

  innerContent(List<RecentFileEntity> group) {
    List<RecentFileEntity> showData;
    double size = (UI.DISPLAY_WIDTH - 40) / 3;
    if (group.length >= 6) {
      showData = group.sublist(0, 5);
    } else {
      showData = group;
    }

    var widgets = showData.map((f) {
      cacheSet.add(f.path);
      return UI.selectPreview(f.path, size);
    }).toList();
    if (group.length >= 6) {
      widgets.add(SizedBox(
        width: size,
        height: size,
        child: Icon(
          Icons.more_horiz,
          size: 30,
        ),
      ));
    }

    return Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: Wrap(
          children: widgets,
        ));
  }

  Future<List<RecentFileEntity>> getRecentFiles() async {
    List<Map> maps = await DBManager.instance
        .queryAll(RecentFileEntity.tableName, 'modifyTime desc'); // for db
    List<RecentFileEntity> result = [];
    if (maps != null && maps.length != 0) {
      maps.forEach((f) {
        result.add(RecentFileEntity.fromMap(f));
      });
    } else {
      List<String> recentList = Common().recentDir;
      List<String> recentFileExt = Common().recentFileExt();
      recentList.forEach(print); // folder
      recentFileExt.forEach(print); // ext
      List<FileSystemEntity> recentFiles = await compute(wapperGetAllFiles,
          {"keys": recentFileExt, "roots": recentList, "isExt": true});
      recentFiles.forEach((f) {
        if (f.statSync().size > 1024) {
          result.add(RecentFileEntity.forSystemFileEntity(f));
          DBManager.instance.insert(RecentFileEntity.tableName, result.last);
        }
      });
    }
    print(result.length);
    return result;
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
  gridView() => GridView.count(
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

  leftTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
