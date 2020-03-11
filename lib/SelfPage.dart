import 'package:bytes_cloud/MarkDownListPage.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelfRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SelfRouteState();
  }
}

class SelfRouteState extends State<SelfRoute>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContextcontext) {
    return Scaffold(
        body: ListView(
      shrinkWrap: true,
      children: <Widget>[
        getAvatorWidget(), // 头像
        //getVolumeWidget(),
        getGridView(),
      ],
    ));
  }

  callMarkDownPage() => Navigator.push(
      context, MaterialPageRoute(builder: (context) => new MarkDownListPage()));

  Widget getGridView() {
    return GridView.count(
      crossAxisCount: 3,
      physics: ScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        UI.iconTxtBtn(Constants.NOTE, "笔记", callMarkDownPage), // 笔记
        UI.iconTxtBtn(Constants.GROUP, "共享", () => {print("")}),
        UI.iconTxtBtn(Constants.MARK, "收藏", () => {print("")}),
        UI.iconTxtBtn(Constants.SHARE, "分享", () => {print("")}), // 分享
        UI.iconTxtBtn(Constants.TRASH, "回收站", () => {print("")}),
        UI.iconTxtBtn(Constants.DOWNLOADED, "已下载", () => {print("")}), // 已下载文件
        UI.iconTxtBtn(Constants.SETTING, "设置", () => {print("")}),
        UI.iconTxtBtn(Constants.FACEBACK, "反馈", () => {print("")}),
      ],
    );
  }

  Widget getAvatorWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 32, 0, 8),
      child: Row(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  "http://b-ssl.duitang.com/uploads/item/201409/25/20140925103211_w3edR.jpeg",
                  width: 80,
                  height: 80,
                  cacheHeight: 80,
                  cacheWidth: 80,
                ),
              )),
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "白茶清欢",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    child: Image.asset(Constants.CHANGE_USER),
                    height: 16,
                  ),
                  Text(
                    '切换账号',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

//  Widget getVolumeWidget() {
//    return Padding(
//      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
//      child: DecoratedBox(
//          decoration: BoxDecoration(
//            shape: BoxShape.rectangle,
//            color: Colors.white,
//          ),
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              Padding(
//                padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
//                child: Text(
//                  "存储空间 3/10 GB",
//                  style: TextStyle(fontSize: 16, color: Colors.lightGreen),
//                ),
//              ),
//              Padding(
//                padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
//                child: LinearProgressIndicator(
//                  value: 0.3,
//                ),
//              ),
//            ],
//          )),
//    );
//  }

  Widget getCircleVolumeWidget(void call()) {
    return InkWell(
      child: Card(
          child: UnconstrainedBox(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(Colors.blue),
            value: .3,
          ),
        ),
      )),
      onTap: call,
    );
  }

  @override
  bool get wantKeepAlive => true;

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
            )
          ];
        });
  }
}
