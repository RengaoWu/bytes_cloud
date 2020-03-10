import 'package:bytes_cloud/common.dart';
import 'package:bytes_cloud/test/SearchView.dart';
import 'package:bytes_cloud/update/DocPushRoute.dart';
import 'package:bytes_cloud/update/FileSelectorRoute.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileTypeUtils.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:bytes_cloud/widgets/Widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../EventBusUtil.dart';
import 'FileSearchPage.dart';
import 'FileSelectorFragment.dart';

class NativeFileSelectorRoute extends StatefulWidget {
  Map<String, dynamic> args;
  NativeFileSelectorRoute(this.args);
  @override
  State<StatefulWidget> createState() {
    return NativeFileSelectorRouteState(args);
  }
}

class NativeFileSelectorRouteState extends State<NativeFileSelectorRoute> {
  Map<String, dynamic> args;
  String root ;
  String rootName;

  FileSelectorFragment fragment;
  NativeFileSelectorRouteState(this.args);

  @override
  void initState() {
    super.initState();
    root = args['root'];
    rootName = args['rootName'];
  }

  @override
  Widget build(BuildContext context) {
    fragment = FileSelectorFragment(root);
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Icon(Icons.arrow_left),
          onTap: () => Navigator.pop(context),
        ),
        title: Text(rootName),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () {
              print('on pressed');
              GlobalEventBus().event.fire(FilesPushEvent());
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          ShareDataWidget(
            root,
            Expanded(child: fragment),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: callNativeFileSearch,
      ),
    );
  }

  callNativeFileSearch() {
    UI.newPage(context, FileSearchPage({'key': '', 'root': root}));
  }

  iconTextBtn(Widget icon, String text, Function call) {
    return UnconstrainedBox(
        child: InkWell(
      onTap: call,
      child: Chip(
        label: Text(text),
        avatar: CircleAvatar(
          child: Padding(
            child: icon,
            padding: EdgeInsets.all(4),
          ),
          backgroundColor: Color.fromARGB(0x00, 0xff, 0xff, 0xff),
        ),
        backgroundColor: Color.fromARGB(0x66, 0xAA, 0xFF, 0xFF),
      ),
    ));
  }
}

class ShareDataWidget extends InheritedWidget {
  String data;
  Widget child;

  ShareDataWidget(this.data, this.child) : super(child: child);

  @override
  bool updateShouldNotify(ShareDataWidget oldWidget) {
    print('data = $data , old data = ${oldWidget.data}');
    return data != oldWidget.data;
  }

  //定义一个便捷方法，方便子树中的widget获取共享数据
  static ShareDataWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(aspect: ShareDataWidget);
  }
}
