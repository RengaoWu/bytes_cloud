import 'package:bytes_cloud/update/NativeFileSelectorRoute.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class RecentRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RecentRouteState();
  }
}

class RecentRouteState extends State<RecentRoute>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.widgets),
            onPressed: () => {
                  UI.bottomSheet(
                      context: context,
                      content: gridView(),
                      height: 240,
                      radius: 8)
                }),
        centerTitle: true,
        title: boldText(
          '最近',
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 0, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '快捷访问',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          gridView()
        ],
      ),
    );
  }

  callDownloadSelector() => UI.newPage(
      context,
      NativeFileSelectorRoute(
          {'root': Common().sDownloadDir, 'rootName': '下载'}));
  callWxSelector() => UI.newPage(context,
      NativeFileSelectorRoute({'root': Common().sWxDir, 'rootName': '微信'}));
  callQQSelector() => UI.newPage(context,
      NativeFileSelectorRoute({'root': Common().sQQDir, 'rootName': 'QQ'}));
  callScreamShotSelector() => UI.newPage(
      context,
      NativeFileSelectorRoute(
          {'root': Common().sScreamShotDir, 'rootName': '截图'}));
  callCameraSelector() => UI.newPage(context,
      NativeFileSelectorRoute({'root': Common().sCameraDir, 'rootName': '相机'}));
  gridView() => GridView.count(
        shrinkWrap: true,
        crossAxisCount: 5,
        children: <Widget>[
          // 快捷访问
          UI.iconTxtBtn(Constants.WECHAT, '微信', callWxSelector),
          UI.iconTxtBtn(Constants.QQ, 'QQ', callQQSelector),
          UI.iconTxtBtn(Constants.DOWNLOADED, '下载', callDownloadSelector),
          UI.iconTxtBtn(Constants.SCREAMSHOT, '截图', callScreamShotSelector),
          UI.iconTxtBtn(Constants.CAMERA, '相机', callCameraSelector),
        ],
      );

  @override
  bool get wantKeepAlive => true;
}
