import 'package:bytes_cloud/update/NativeFileSelectorRoute.dart';
import 'package:bytes_cloud/update/PhotoPushRoute.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'NativeRoute.dart';
import 'PhotoPage.dart';
import 'SelfPage.dart';
import 'common.dart';

class HomeRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeRouteState();
  }
}

class HomeRouteState extends State<HomeRoute>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new TabBarView(controller: tabController, children: <Widget>[
        RecentRoute(),
        NativeRoute(),
        RemoteRoute(),
        SelfRoute()
      ]),
      bottomNavigationBar: new Material(
        child: new TabBar(
            controller: tabController,
            labelColor: Colors.deepPurpleAccent,
            unselectedLabelColor: Colors.black26,
            tabs: <Widget>[
              new Tab(
                text: '最近',
                icon: new Icon(Icons.recent_actors),
              ),
              new Tab(
                text: '分类',
                icon: new Icon(Icons.cloud),
              ),
              new Tab(
                text: '云盘',
                icon: new Icon(Icons.photo),
              ),
              new Tab(
                text: '我的',
                icon: new Icon(Icons.person),
              )
            ]),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }
}

class RecentRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RecentRouteState();
  }
}

class RecentRouteState extends State<RecentRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.widgets),
            onPressed: () => {
                  UI.bottomSheet(
                      context: context,
                      content: gridView(),
                      height: 240,
                      radius: 8)
                }),
        centerTitle: true,
        title: Text('最近'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 0, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '快捷访问',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          gridView()
        ],
      ),
    );
  }

  callDownloadSelector() => UI.newPage(
      context,
      NativeFileSelectorRoute(
          {'root': Common().sDownloadDir, 'rootName': '下载'}));
  callWxSelector() => UI.newPage(context,
      NativeFileSelectorRoute({'root': Common().sWxDir, 'rootName': '微信'}));
  callQQSelector() => UI.newPage(context,
      NativeFileSelectorRoute({'root': Common().sQQDir, 'rootName': 'QQ'}));

  gridView() => GridView.count(
        shrinkWrap: true,
        crossAxisCount: 5,
        children: <Widget>[
          // 快捷访问
          UI.iconTxtBtn(Constants.DOWNLOADED, '下载', callDownloadSelector),
          UI.iconTxtBtn(Constants.WECHAT, '微信', callWxSelector),
          UI.iconTxtBtn(Constants.QQ, 'QQ', callQQSelector),
          UI.iconTxtBtn(Constants.PHOTO, '截图', null),
        ],
      );
}
