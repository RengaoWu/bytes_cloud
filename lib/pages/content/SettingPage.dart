import 'package:bytes_cloud/pages/content/ThemeSwitchPage.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/SPWrapper.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingPageState();
  }
}

class SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        leading: BackButton(),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[ThemeSwitcher()],
      ),
    );
  }
}

// 提供五套可选主题色
const _themes = <MaterialColor>[
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
    return _themes.firstWhere(
        (f) => f.value == SPUtil.getInt('COLOR', Colors.blue.value));
  }

  // 主题改变后，通知其依赖项，新主题会立即生效
  set theme(ColorSwatch color) {
    if (color != theme) {
      SPUtil.setInt('COLOR', color.value);
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    super.notifyListeners(); //通知依赖的Widget更新
  }
}

class ThemeSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      UI.leftTitle('主题选择',
          paddingLeft: 16,
          paddingTop: 8,
          size: 14,
          fontWeight: FontWeight.normal),
      Row(
        children: _themes.map<Widget>((e) {
          return Expanded(
              child: GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(left: 10, top: 8, right: 10),
              child: Container(
                color: e,
                alignment: Alignment.bottomCenter,
                height: 80,
              ),
            ),
            onTap: () {
              //主题更新后，MaterialApp会重新build
              Provider.of<ThemeModel>(context, listen: false).theme = e;
            },
          ));
        }).toList(),
      ),
      Divider(
        indent: 8,
        endIndent: 8,
      )
    ]);
  }
}
