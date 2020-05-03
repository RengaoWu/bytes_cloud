import 'dart:ui';

import 'package:bytes_cloud/core/Common.dart';
import 'package:bytes_cloud/pages/content/MDListPage.dart';
import 'package:bytes_cloud/pages/selectors/PhotoPushRoute.dart';
import 'package:bytes_cloud/pages/selectors/SearchFilePage.dart';
import 'package:bytes_cloud/pages/selectors/SysFileSelectorPage.dart';
import 'package:bytes_cloud/pages/selectors/TypeFileSelectorPage.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileTypeConfig.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NativeRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NativeRouteState();
  }
}

class NativeRouteState extends State<NativeRoute>
    with AutomaticKeepAliveClientMixin {
  final controller = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Column 导致 gridView 有一个未知的padding
    // 用ListView
    return Scaffold(
        body: Column(
      //physics: ScrollPhysics(),
      children: <Widget>[
        Container(
          color: Theme.of(context).primaryColor,
          height: MediaQueryData.fromWindow(window).padding.top,
        ),
        UI.searchBar(context, controller, (k) {
          UI.newPage(
              context,
              SearchFilePage({
                'key': k,
                'roots': [Common.sd]
              }));
        }),
        gridView(),
        UI.divider(width: 2, padding: 16),
        nativeFileSystem(),
        UI.divider(width: 1, padding: 16),
      ],
    ));
  }

  nativeFileSystem() {
    return ListTile(
      leading: Image.asset(
        Constants.PHONE,
        width: 40,
        height: 40,
      ),
      title: boldText('内部存储'),
      subtitle: Text(
        '已使用 12.81/64GB',
        style: TextStyle(fontSize: 12),
      ),
      trailing: Icon(Icons.arrow_right),
      onTap: callFileSelectorPage,
    );
  }

  callVideoSelectorPage() =>
      UI.newPage(context, TypeFileSelectorPage(FileTypeConfig.ARG_VIDEO));

  callPhotoSelectorPage() => UI.newPage(
      context, PhotoPushRoute(type: PhotoPushRoute.TYPE_OPEN_SELECT));

  callFileSelectorPage() => UI.newPage(
      context, SysFileSelectorPage({'root': Common.sd, 'rootName': '根目录'}));

  callDocTypeSelector() =>
      UI.newPage(context, TypeFileSelectorPage(FileTypeConfig.ARG_DOC));

  callZipTypeSelector() =>
      UI.newPage(context, TypeFileSelectorPage(FileTypeConfig.ARG_ZIP));

  callMusicSelector() =>
      UI.newPage(context, TypeFileSelectorPage(FileTypeConfig.ARG_MUSIC));

  callMarkDownPage() => UI.newPage(context, MarkDownListPage());

  gridView() => Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: GridView.count(
          crossAxisCount: 4,
          physics: ScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            UI.iconTxtBtn(Constants.PHOTO, "图片", callPhotoSelectorPage),
            UI.iconTxtBtn(Constants.VIDEO, "视频", callVideoSelectorPage),
            UI.iconTxtBtn(Constants.MUSIC, "音乐", callMusicSelector),
            UI.iconTxtBtn(Constants.DOC, "文档", callDocTypeSelector),
//            UI.iconTxtBtn(Constants.FILE2, "文件", callFileSelectorPage),
            UI.iconTxtBtn(Constants.COMPRESSFILE, "压缩包", callZipTypeSelector),
            UI.iconTxtBtn(Constants.NOTE, "笔记", callMarkDownPage),
            UI.iconTxtBtn(Constants.MCF, "语言", () => {print("")}),
            UI.iconTxtBtn(Constants.SCAN, "扫描", () => {print("")}),
          ],
        ),
      );

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
