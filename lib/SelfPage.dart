import 'package:bytes_cloud/MarkDownPage.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: ListView(
          children: <Widget>[
            getAvatorWidget(), // 头像
            getVolumeWidget(),
            getGridView(),
          ],
        ));
  }

  Widget getGridView() {
    return GridView.count(
      crossAxisCount: 4,
      physics: ScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        getTextItemWidget(
            Icons.bookmark,
            "笔记",
            () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => new MarkDownListPage()))
                }), // 笔记
        getTextItemWidget(Icons.group, "共享", () => {print("")}),

        getTextItemWidget(Icons.star, "收藏", () => {print("")}),
        getTextItemWidget(Icons.share, "分享", () => {print("")}), // 分享
        getTextItemWidget(
            Icons.delete_outline, "回收站", () => {print("")}), // 回收站
        getTextItemWidget(
            Icons.file_download, "已下载", () => {print("")}), // 已下载文件

        getTextItemWidget(Icons.settings, "设置", () => {print("")}),
        getTextItemWidget(Icons.email, "反馈", () => {print("")}),
      ],
    );
  }

  Widget getAvatorWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 32, 0, 0),
      child: Card(
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8),
              child: Image(
                image: NetworkImage(
                    "http://b-ssl.duitang.com/uploads/item/201409/25/20140925103211_w3edR.jpeg"),
                width: 60,
                height: 60,
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  "白茶清欢",
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                Icon(
                  Icons.autorenew,
                  color: Colors.grey,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getVolumeWidget() {
    return Card(
        child: Padding(
      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Text(
                  "存储空间 3/10 GB",
                  style: TextStyle(fontSize: 16, color: Colors.lightGreen),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: LinearProgressIndicator(
                  value: 0.3,
                ),
              ),
            ],
          )),
    ));
  }

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

  Widget getTextItemWidget(IconData icon, String title, void call()) {
    return InkWell(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 24,
              color: Colors.blue,
            ),
            Text(
              "$title",
              style: TextStyle(fontSize: 14),
            )
          ],
        ),
      ),
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
