import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelfRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SelfRouteState();
  }
}

class SelfRouteState extends State<SelfRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Personal'),
        ),
        body: Column(
          children: <Widget>[
            getAvatorWidget(), // 头像
            getVolumeWidget(), // 容器
            getTextItemWidge(Icons.bookmark, "笔记", () => {print("hhhh")})
          ],
        ));
  }

  Widget getAvatorWidget() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: DecoratedBox(
          decoration:
              BoxDecoration(shape: BoxShape.rectangle, color: Colors.white),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16),
                child: Image(
                  image: NetworkImage(
                      "http://b-ssl.duitang.com/uploads/item/201409/25/20140925103211_w3edR.jpeg"),
                  width: 60,
                  height: 60,
                ),
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: Text(
                      "白茶清欢",
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Text(
                    "Switch account",
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              )
            ],
          ),
        ));
  }

  Widget getVolumeWidget() {
    return Padding(
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
                  "存储空间",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: LinearProgressIndicator(
                  value: 0.3,
                ),
              ),
            ],
          ),
        ));
  }

  Widget getTextItemWidge(IconData icon, String title, void call()) {
    return InkWell(
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: Colors.blue,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      onTap: call,
    );
  }
}
