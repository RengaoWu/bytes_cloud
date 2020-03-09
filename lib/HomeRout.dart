import 'package:bytes_cloud/update/NativeFileRoute.dart';
import 'package:bytes_cloud/update/PhotoPushRoute.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/UI.dart';
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
                text: '最近',
                icon: new Icon(Icons.recent_actors),
              ),
              new Tab(
                text: '文件',
                icon: new Icon(Icons.cloud),
              ),
              new Tab(
                text: '图片',
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
      body: Center(
        child: Text('最近'),
      ),
    );
  }

  callPhotoSelectorPage() {
    Navigator.pop(context);
    UI.newPage(context, PhotoPushRoute(type: PhotoPushRoute.TYPE_OPEN_SELECT));
  }

  callFileSelectorPage() {
    Navigator.pop(context);
    UI.newPage(context, NativeFileRoute());
  }

  gridView() => GridView.count(
        crossAxisCount: 4,
        children: <Widget>[
          UI.iconTxtBtn(Constants.PHOTO, "图片", callPhotoSelectorPage),
          UI.iconTxtBtn(Constants.FILE2, "文件", callFileSelectorPage),
          UI.iconTxtBtn(Constants.DOC, "文档", () => {print("")}),
          UI.iconTxtBtn(Constants.FOLDER, "新建文件夹", () => {print("")}),
          UI.iconTxtBtn(Constants.NOTE, "写笔记", () => {print("")}),
          UI.iconTxtBtn(Constants.MCF, "语言速记", () => {print("")}),
          UI.iconTxtBtn(Constants.SCAN, "智能扫描", () => {print("")}),
        ],
      );
}
