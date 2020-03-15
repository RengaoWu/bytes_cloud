import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RemoteRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RemoteRouteState();
  }
}

class RemoteRouteState extends State<RemoteRoute>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController tabController;
  List<String> tabs = ["Time", "Location", "Album"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: getSliverPage(
          body: TabBarView(
              controller: tabController,
              children: tabs
                  .map((e) => Tab(
                        text: e,
                      ))
                  .toList())),
    );
  }

  Widget getSliverPage({Widget body}) {
    return NestedScrollView(
        body: body,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text(
                'Photo',
                style: TextStyle(color: Colors.deepOrange),
              ),
              pinned: false, // 向下滑动是否保留 bottom
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: Image.network(
                  'https://cdn.duitang.com/uploads/item/201408/11/20140811200850_LUY5c.png',
                  fit: BoxFit.cover,
                ),
              ),
              expandedHeight: 200,
              forceElevated: innerBoxIsScrolled,
              floating: true,
              bottom: new TabBar(
                  indicatorColor: Colors.deepOrange,
                  labelColor: Colors.deepOrange,
                  controller: tabController,
                  tabs: tabs
                      .map((e) => Tab(
                            text: e,
                          ))
                      .toList()),
            )
          ];
        });
  }

  @override
  bool get wantKeepAlive => true;
}
