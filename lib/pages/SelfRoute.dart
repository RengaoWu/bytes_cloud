import 'package:bytes_cloud/pages/content/DownloadPage.dart';
import 'package:bytes_cloud/pages/content/MDListPage.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelfRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SelfRouteState();
  }
}

class SelfRouteState extends State<SelfRoute>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: MediaQuery.removePadding(
      child: Column(
        children: <Widget>[
          headerView(), // 头像
          bodyView(),
          footerView(),
        ],
      ),
      context: context,
    ));
  }

  footerView() {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Card(
        child: Column(
          children: <Widget>[
            listTitle(
                Constants.NIGHT,
                '夜间模式',
                Switch(
                  value: false,
                  onChanged: (value) {},
                ),
                null,
                left: 8,
                top: 4,
                right: 8),
            Divider(
              indent: 8,
              endIndent: 8,
            ),
            listTitle(Constants.SETTING, '设置', null, null,
                left: 8, right: 8, top: 8, bottom: 8),
            Divider(
              indent: 8,
              endIndent: 8,
            ),
            listTitle(Constants.FACEBACK, '反馈', null, null,
                left: 8, right: 8, bottom: 16, top: 16),
          ],
        ),
      ),
    );
  }

  listTitle(String icon, String content, Widget tail, Function call,
      {double top = 0, double left = 0, double right = 0, double bottom = 0}) {
    return Container(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Image.asset(
              icon,
              width: 24,
            ),
          ),
          Expanded(child: boldText(content)),
          tail != null ? tail : SizedBox()
        ],
      ),
    );
  }

  callMarkDownPage() => Navigator.push(
      context, MaterialPageRoute(builder: (context) => new MarkDownListPage()));

  Widget bodyView() {
    return Container(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Card(
            child: Column(children: <Widget>[
          UI.leftTitle('云盘功能', paddingLeft: 24, paddingTop: 16, size: 16),
          MediaQuery.removePadding(
            removeTop: true,
            child: GridView.count(
              crossAxisCount: 4,
              physics: ScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                UI.iconTxtBtn(Constants.BACK, "备份", () => {print("")}),
                UI.iconTxtBtn(Constants.GROUP, "共享", () => {print("")}),
                UI.iconTxtBtn(Constants.MARK, "收藏", () => {print("")}),
                UI.iconTxtBtn(Constants.SHARE, "分享", () => {print("")}), // 分享
                UI.iconTxtBtn(Constants.TRASH, "回收站", () => {print("")}),
                UI.iconTxtBtn(Constants.DOWNLOADED, "已下载",
                    () => UI.newPage(context, DownloadPage())), // 已下载文件
              ],
            ),
            context: context,
          )
        ])));
  }

  Widget headerView() {
    return Container(
      height: 220,
      padding: EdgeInsets.only(bottom: 16),
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          Image.network(
            'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1584635196741&di=bbc124b387b8cc030e2c4a7ed3510c9a&imgtype=0&src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201401%2F23%2F095609lsejfi4thjrrwydj.jpg',
            fit: BoxFit.cover,
            height: 240,
          ),
          Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: UnconstrainedBox(
                  child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  "http://b-ssl.duitang.com/uploads/item/201409/25/20140925103211_w3edR.jpeg",
                  width: 80,
                  height: 80,
                ),
              ))),
          Positioned(
            left: 0,
            right: 0,
            top: 120,
            child: UnconstrainedBox(
                child: Text('白茶清欢',
                    style: TextStyle(fontSize: 18, color: Colors.white))),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: IconButton(
              icon: Icon(
                Icons.compare_arrows,
                size: 28,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
