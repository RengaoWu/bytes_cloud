import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'CloudPage.dart';
import 'PhotoPage.dart';
import 'SelfPage.dart';

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
        CloudRoute(),
        PhotoRoute(),
        SelfRoute()
      ]),
      bottomNavigationBar: new Material(
        child: new TabBar(
            controller: tabController,
            labelColor: Colors.deepPurpleAccent,
            unselectedLabelColor: Colors.black26,
            tabs: <Widget>[
              new Tab(
                text: 'Recnet',
                icon: new Icon(Icons.recent_actors),
              ),
              new Tab(
                text: "File",
                icon: new Icon(Icons.cloud),
              ),
              new Tab(
                text: "Photo",
                icon: new Icon(Icons.photo),
              ),
              new Tab(
                text: 'Self',
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
            icon: Icon(Icons.file_download),
            onPressed: () => {print("on press hhh")}),
        centerTitle: true,
        title: Text('Recent'),
      ),
      body: Center(
        child: Text('Recnet'),
      ),
    );
  }
}
