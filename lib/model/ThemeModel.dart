// 提供五套可选主题色
import 'package:bytes_cloud/utils/SPUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Themes = <MaterialColor>[
  Colors.blue,
  Colors.purple,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red,
];

class ThemeModel extends ChangeNotifier {
  // 获取当前主题，如果为设置主题，则默认使用蓝色主题
  ColorSwatch get theme {
    return Themes.firstWhere(
        (f) => f.value == SP.getInt('COLOR', Colors.blue.value));
  }

  // 主题改变后，通知其依赖项，新主题会立即生效
  set theme(ColorSwatch color) {
    if (color != theme) {
      SP.setInt('COLOR', color.value);
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    super.notifyListeners(); //通知依赖的Widget更新
  }
}
