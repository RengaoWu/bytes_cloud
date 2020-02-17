import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetUtils {
  static Widget getDivider(
      {color = Colors.grey, double padding = 0, width = 0.5}) {
    return Padding(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
        child: DecoratedBox(
          decoration:
              BoxDecoration(border: Border.all(color: color, width: 0.5)),
        ));
  }
}
