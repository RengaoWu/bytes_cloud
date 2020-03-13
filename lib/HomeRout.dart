import 'package:bytes_cloud/update/SysFileSelectorPage.dart';
import 'package:bytes_cloud/update/PhotoPushRoute.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'NativeRoute.dart';
import 'PhotoPage.dart';
import 'RecentRoute.dart';
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
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.blueGrey,
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
