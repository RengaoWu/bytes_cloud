import 'package:bytes_cloud/update/DocPushRoute.dart';
import 'package:bytes_cloud/update/TypeSelectorRoute.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileTypeUtils.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../EventBusUtil.dart';
import 'FileSelectorFragment.dart';

class FilePushRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FilePushRouteState();
  }
}

class FilePushRouteState extends State<FilePushRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Icon(Icons.arrow_left),
          onTap: () => Navigator.pop(context),
        ),
        title: Text('根目录'),
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
          Expanded(child: FileSelectorFragment()),
        ],
      ),
    );
  }

  fileTypeGridView() {
    return Wrap(
      spacing: 8.0, // 主轴(水平)方向间距
      alignment: WrapAlignment.center, //沿主轴方向居中
      children: <Widget>[
        iconTextBtn(Image.asset(Constants.NOTE), '文档', callDocTypeSelector),
        iconTextBtn(Image.asset(Constants.ZIP), '压缩包', callZipTypeSelector),
        iconTextBtn(Image.asset(Constants.MP3), '音乐', callMusicSelector),
        iconTextBtn(Image.asset(Constants.DOWNLOADED), '下载', null),
        iconTextBtn(Image.asset(Constants.WECHAT), '来自微信', null),
        iconTextBtn(Image.asset(Constants.QQ), '来自QQ', null),
      ],
    );
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
