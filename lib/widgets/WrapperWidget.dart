import 'package:flutter/cupertino.dart';

class WidgetUtils {
  static Widget PaddingWidget({Widget child, double padding}) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}
