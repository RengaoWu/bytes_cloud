import 'dart:io';

import 'package:bytes_cloud/core/common.dart';
import 'package:bytes_cloud/entity/DBManager.dart';
import 'package:bytes_cloud/entity/entitys.dart';
import 'package:bytes_cloud/pages/selectors/SysFileSelectorPage.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/IoslateMethods.dart';
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
      body: Scrollbar(
          child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          leftTitle('快捷访问'),
          gridView(),
          UI.divider(width: 2, padding: 8),
          listView(),
        ],
      )),
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
          Map<String, List<RecentFileEntity>> map = {};
          print("recentList ${recentList.length}");
          print('FutureBuilder ' + DateTime.now().toIso8601String());
          recentList.forEach((f) {
            if (f == null) {
              print('f is null');
            }
            DateTime modifyTime =
                DateTime.fromMillisecondsSinceEpoch(f.createTime);
            String date =
                " ${modifyTime.year}年 ${modifyTime.month}月 ${modifyTime.day}日";
            if (map.containsKey(date)) {
              map[date].add(f);
            } else {
              map[date] = [f];
            }
          });
          print('FutureBuilder ' + DateTime.now().toIso8601String());
          List<MapEntry<String, List<RecentFileEntity>>> list =
              map.entries.toList();
          ListView view = ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              physics: new NeverScrollableScrollPhysics(), //禁用滑动事件
              itemBuilder: (BuildContext context, int index) {
                return Text(
                    'Time : ${list[index].key} , ${list[index].value.length}');
              });
          return view;
        }
        print(snapshot.error.toString());
        return Text(snapshot.error.toString());
      },
    );
  }

  Future<List<RecentFileEntity>> getRecentFiles() async {
    List<Map> maps = await DBManager.instance
        .queryAll(RecentFileEntity.tableName, 'modifyTime desc'); // for db
    List<RecentFileEntity> result = [];
    if (maps != null && maps.length != 0) {
      maps.forEach((f) {
        result.add(RecentFileEntity.fromMap(f));
      });
//      result = maps.map((map) {
//        RecentFileEntity.fromMap(map); //
//      }).toList();
    } else {
      List<String> recentList = Common().recentDir;
      List<String> recentFileExt = Common().recentFileExt();
      recentList.forEach(print); // folder
      recentFileExt.forEach(print); // ext
      List<FileSystemEntity> recentFiles = await compute(wapperGetAllFiles,
          {"keys": recentFileExt, "roots": recentList, "isExt": true});
      recentFiles.forEach((f) {
        result.add(RecentFileEntity.forSystemFileEntity(f));
        DBManager.instance.insert(RecentFileEntity.tableName, result.last);
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
      padding: EdgeInsets.fromLTRB(16, 8, 0, 0),
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
