import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'NativeRoute.dart';
import 'RemoteRoute.dart';
import 'RecentRoute.dart';
import 'SelfRoute.dart';

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
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    UI.DISPLAY_WIDTH = size.width;
    UI.DISPLAY_HEIGHT = size.height;

    return Scaffold(
      body: TabBarView(controller: tabController, children: <Widget>[
        RecentRoute(),
        NativeRoute(),
        RemoteRoute(),
        SelfRoute()
      ]),
      bottomNavigationBar: new Material(
        child: new TabBar(
            controller: tabController,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
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
