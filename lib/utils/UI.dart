import 'package:flutter/material.dart';

import 'Constants.dart';

class UI {
  static newPage(BuildContext context, Widget widget) => Navigator.push(
      context, new MaterialPageRoute(builder: (context) => widget));

  static Widget divider(
      {color = Colors.grey, double padding = 0, double width = 0.5}) {
    return Padding(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
        child: DecoratedBox(
          decoration:
              BoxDecoration(border: Border.all(color: color, width: width)),
        ));
  }

  static appbarBtn(IconData icon,
      {BuildContext context, void call(BuildContext context)}) {
    return Builder(builder: (BuildContext context) {
      return Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: IconButton(
            onPressed: () {
              if (call != null) call(context);
            },
            icon: new Icon(icon),
          ));
    });
  }

  static showProgressDialog<T>(
      {@required BuildContext context,
      Future<T> future,
      String title,
      void successCall(String data),
      void failCall(String errMsg)}) {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: FutureBuilder(
              future: future,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                // 请求已结束
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    failCall(snapshot.error);
                  } else {
                    successCall(snapshot.data);
                  }
                  Navigator.pop(context);
                  return CircularProgressIndicator();
                } else {
                  // 请求未结束，显示loading
                  return CircularProgressIndicator();
                }
              },
            ),
          );
        });
  }

  static showMessageDialog(
      {@required BuildContext context,
      String title = '',
      Widget content,
      Map<String, Function> map}) {
    List<Widget> actions = [];
    if (map != null) {
      map.forEach((w, c) {
        actions.add(FlatButton(onPressed: c, child: Text(w)));
      });
    }

    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: content,
            actions: actions,
          );
        });
  }

  static Widget borderDeco(
      Widget child, bool left, bool top, bool right, bool bottom) {
    return DecoratedBox(
      child: child,
      decoration: BoxDecoration(
          border: Border(
        left: left ? BorderSide(width: 0.5) : BorderSide.none,
        top: top ? BorderSide(width: 0.5) : BorderSide.none,
        right: right ? BorderSide(width: 0.5) : BorderSide.none,
        bottom: bottom ? BorderSide(width: 0.5) : BorderSide.none,
      )),
    );
  }

  static Widget iconTxtBtn(String image, String title, void call()) {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 24,
            height: 40,
            child: Image.asset(image),
          ),
          Text(
            "$title",
            style: TextStyle(fontSize: 14),
          )
        ],
      ),
      onTap: call,
    );
  }

  static bottomSheet(
          {@required BuildContext context,
          @required Widget content,
          double height = 400,
          double radius = 10}) =>
      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return SizedBox(
                height: height,
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: height,
                      width: double.infinity,
                      color: Colors.black54,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(radius),
                            topRight: Radius.circular(radius),
                          )),
                    ),
                    Container(
                      child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(top: 24.0),
                          child: content),
                    ),
                  ],
                ));
          });
}
