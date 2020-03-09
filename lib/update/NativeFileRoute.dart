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

class NativeFileRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NativeFileRouteState();
  }
}

class NativeFileRouteState extends State<NativeFileRoute> {
  String root = Common().sDCardDir;
  String rootName = '根目录';

  FileSelectorFragment fragment;
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
          fileTypeGridView(),
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
    UI.newPage(context, FileSearchPage());
  }

  fileTypeGridView() {
    return Wrap(
      spacing: 8.0, // 主轴(水平)方向间距
      alignment: WrapAlignment.center, //沿主轴方向居中
      children: <Widget>[
        iconTextBtn(Text('A'), '根目录', callRootSelector),
        iconTextBtn(Image.asset(Constants.NOTE), '文档', callDocTypeSelector),
        iconTextBtn(
            Image.asset(Constants.COMPRESSFILE), '压缩包', callZipTypeSelector),
        iconTextBtn(Image.asset(Constants.MUSIC), '音乐', callMusicSelector),
        iconTextBtn(
            Image.asset(Constants.DOWNLOADED), '下载', callDownloadSelector),
        iconTextBtn(Image.asset(Constants.WECHAT), '微信', callWxSelector),
        iconTextBtn(Image.asset(Constants.QQ), 'QQ', callQQSelector),
      ],
    );
  }

  callRootSelector() {
    setState(() {
      root = Common().sDCardDir;
      rootName = '根目录';
    });
  }

  callDocTypeSelector() {
    UI.newPage(context, TypeSelectorRoute(FileTypeUtils.ARG_DOC));
  }

  callZipTypeSelector() {
    UI.newPage(context, TypeSelectorRoute(FileTypeUtils.ARG_ZIP));
  }

  callMusicSelector() {
    UI.newPage(context, TypeSelectorRoute(FileTypeUtils.ARG_MUSIC));
  }

  callDownloadSelector() {
    setState(() {
      root = Common().sDownloadDir;
      rootName = '下载';
    });
  }

  callWxSelector() {
    setState(() {
      root = Common().sWxDir;
      rootName = '微信';
    });
  }

  callQQSelector() {
    setState(() {
      root = Common().sQQDir;
      rootName = 'QQ';
    });
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
