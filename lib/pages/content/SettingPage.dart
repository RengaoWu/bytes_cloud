import 'package:bytes_cloud/model/ThemeModel.dart';
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
        children: Themes.map<Widget>((e) {
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
