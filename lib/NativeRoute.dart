import 'dart:ui';

import 'package:bytes_cloud/FileManager.dart';
import 'package:bytes_cloud/MarkDownListPage.dart';
import 'package:bytes_cloud/common.dart';
import 'package:bytes_cloud/update/SearchFilePage.dart';
import 'package:bytes_cloud/update/TypeFileSelectorPage.dart';
import 'package:bytes_cloud/update/SysFileSelectorPage.dart';
import 'package:bytes_cloud/update/PhotoPushRoute.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileTypeUtils.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SearchRoute.dart';

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
        body: ListView(
      physics: ScrollPhysics(),
      children: <Widget>[
        searchBar(),
        gridView(),
        UI.divider(width: 1, padding: 16),
        nativeFileSystem(),
        UI.divider(padding: 16),
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
      UI.newPage(context, TypeFileSelectorPage(FileTypeUtils.ARG_VIDEO));

  callPhotoSelectorPage() => UI.newPage(
      context, PhotoPushRoute(type: PhotoPushRoute.TYPE_OPEN_SELECT));

  callFileSelectorPage() => UI.newPage(
      context, SysFileSelectorPage({'root': Common().sd, 'rootName': '根目录'}));

  callDocTypeSelector() =>
      UI.newPage(context, TypeFileSelectorPage(FileTypeUtils.ARG_DOC));

  callZipTypeSelector() =>
      UI.newPage(context, TypeFileSelectorPage(FileTypeUtils.ARG_ZIP));

  callMusicSelector() =>
      UI.newPage(context, TypeFileSelectorPage(FileTypeUtils.ARG_MUSIC));

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

  Widget getSearchWidget() {
    return Center(
        child: Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                showSearch(context: context, delegate: SearchBarDelegate());
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  boldText(
                    'Search',
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.sort,
            color: Colors.grey,
          )
        ],
      ),
    ));
  }

  searchBar() => Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.only(top: 0
              //top: MediaQueryData.fromWindow(window).padding.top,
              ),
          child: Container(
            height: 60.0,
            child: new Padding(
                padding: const EdgeInsets.all(4.0),
                child: new Card(
                    child: new Container(
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 5.0,
                      ),
                      Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: new InputDecoration(
                            hintText: '搜索',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (String k) {
                            UI.newPage(
                                context,
                                SearchFilePage(
                                    {'key': k, 'root': Common().sd}));
                          },
                          // onChanged: onSearchTextChanged,
                        ),
                      ),
                      IconButton(
                        icon: new Icon(Icons.cancel),
                        color: Colors.grey,
                        iconSize: 18.0,
                        onPressed: () {
                          controller.clear();
                          // onSearchTextChanged('');
                        },
                      ),
                    ],
                  ),
                ))),
          ),
        ),
      );

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
