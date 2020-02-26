import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UI {
  static newPage(BuildContext context, Widget widget) => Navigator.push(
      context, new MaterialPageRoute(builder: (context) => widget));

  static Widget divider(
      {color = Colors.grey, double padding = 0, width = 0.5}) {
    return Padding(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
        child: DecoratedBox(
          decoration:
              BoxDecoration(border: Border.all(color: color, width: 0.5)),
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

  static showProgressDialog(
      {@required BuildContext context,
      Future future,
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
      String title,
      Widget content,
      Map<String, Function> map}) {
    List<Widget> actions = [];
    map.forEach((w, c) {
      actions.add(FlatButton(onPressed: c, child: Text(w)));
    });
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

  Widget CheckboxTitle(
      {IconData icon, String text, bool value, Function call}) {
    return InkWell(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              Icon(icon),
              Checkbox(value: value, onChanged: call),
              Text(text),
            ],
          ),
        ));
  }
}
