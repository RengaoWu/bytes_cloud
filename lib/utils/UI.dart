import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UI {
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
}
