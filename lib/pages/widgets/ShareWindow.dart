import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bytes_cloud/core/Constants.dart';
import 'package:bytes_cloud/core/http/http.dart';
import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/entity/ShareEntity.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fluwx/fluwx.dart';

class ShareWindow extends StatefulWidget {
  final CloudFileEntity entity;
  ShareWindow(this.entity);
  @override
  State<StatefulWidget> createState() {
    return ShareWindowState();
  }
}

class ShareWindowState extends State<ShareWindow> {
  CloudFileEntity entity;
  ShareEntity shareEntity;
  bool needToken = true;
  int day = 7;
  GlobalKey qrCodeKey = new GlobalKey();
  @override
  void initState() {
    super.initState();
    entity = widget.entity;
  }

  @override
  Widget build(BuildContext context) {
    return generateShareUI();
  }

  generateShareUI() {
    Widget icon;
    if (FileUtil.isImage(entity.fileName)) {
      icon = Hero(
        child: Image.network(
          getPreviewUrl(entity.id, UI.dpi2px(200), UI.dpi2px(200)),
          height: 130,
          fit: BoxFit.cover,
        ),
        tag: entity.id,
      );
    } else {
      icon = UI.selectIcon(entity.fileName, true, size: 120);
    }
    String timeTitle;
    String timeSubTitle;
    if (day == -1) {
      timeTitle = '永久有效';
      timeSubTitle = '在手动取消前，分享将持续有效';
    } else if (day == 31) {
      timeTitle = '一个月内有效';
      timeSubTitle = '分享将在${day}后失效';
    } else {
      timeTitle = '${day}天内有效';
      timeSubTitle = '分享将在${day}后失效';
    }
    return Padding(
      child: ListView(
        children: <Widget>[
          boldText('${entity.fileName}'),
          Padding(
            child: icon,
            padding: EdgeInsets.only(top: 8),
          ),
          ListTile(
            title: Text(timeTitle),
            subtitle: Text(timeSubTitle),
            trailing: Icon(Icons.chevron_right),
            onTap: () async {
              listTitle(String title, String subTitle, int day, bool curr) {
                return ListTile(
                  title: Text(title),
                  subtitle: Text(subTitle),
                  trailing: curr ? Icon(Icons.done) : SizedBox(),
                  onTap: () {
                    Navigator.pop(context, [day]);
                  },
                );
              }

              List d = (await UI.bottomSheet(
                  context: context,
                  content: Column(
                    children: <Widget>[
                      Container(
                        child: boldText('有效期设置', fontSize: 16),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 8),
                      ),
                      listTitle('7天内有效', '', 7, (day == 7)),
                      listTitle('一个月有效', '31天', 31, (day == 31)),
                      listTitle('永久有效', '我的 - 分享 中可以删除', -1, (day == -1)),
                    ],
                  ),
                  height: 300));
              if (d == null || d.length <= 0) return;
              setState(() {
                day = d[0];
              });
            },
          ),
          ListTile(
            title: Text('需要验证'),
            trailing: Switch(
              value: needToken,
              onChanged: (value) {
                setState(() {
                  shareEntity = null;
                  needToken = !needToken;
                });
              },
            ),
          ),
          Row(
            children: <Widget>[
              shareItem(Constants.LINK, '分享链接', () async {
                if (shareEntity == null) {
                  shareEntity = await CloudFileManager.instance()
                      .shareFile(entity.id, needToken, day);
                }
                Clipboard.setData(ClipboardData(text: shareEntity.shareURL));
                Fluttertoast.showToast(msg: '复制到剪切板');
                Navigator.pop(context);
              }),
              shareItem(Constants.QRCODE, '生成二维码', () {
                UI.showContentDialog(
                    context,
                    "分享文件",
                    FutureBuilder<ShareEntity>(
                      future: CloudFileManager.instance()
                          .shareFile(entity.id, needToken, day),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: SizedBox(
                            child: CircularProgressIndicator(),
                            width: 100,
                            height: 100,
                          ));
                        }
                        if (snapshot.hasData) {
                          shareEntity = snapshot.data;
                          return RepaintBoundary(
                              key: qrCodeKey,
                              child: Column(
                                children: <Widget>[
                                  boldText(entity.fileName),
                                  QrImage(
                                    data: shareEntity.getShareDownloadURL,
                                  ),
                                  Text(
                                    '来自ByteCloud',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ));
                        } else {
                          return Center(child: Text('Ops!'));
                        }
                      },
                    ),
                    left: '保存', leftCall: () async {
                  shareEntity.qrCodeFile =
                      await FileUtil.saveUI2Image(qrCodeKey);
                  Navigator.pop(context);
                }, right: '分享', rightCall: shareQrCode);
              }),
            ],
          ),
        ],
      ),
      padding: EdgeInsets.all(8),
    );
  }

  Widget shareItem(String icon, String hint, Function onPressed) {
    return Expanded(
        child: Column(
      children: <Widget>[
        IconButton(
          icon: Image.asset(icon),
          onPressed: onPressed,
          iconSize: 48,
        ),
        Text(hint),
      ],
    ));
  }

  // appid 还没有申请下来，害
  shareQrCode() async {
    print(shareEntity.qrCodeFile);
    if (!FileUtil.isFile(shareEntity.qrCodeFile)) {
      shareEntity.qrCodeFile = await FileUtil.saveUI2Image(qrCodeKey);
    }
    print(shareEntity.qrCodeFile);
    shareToWeChat(WeChatShareImageModel(
      WeChatImage.file(File(shareEntity.qrCodeFile), suffix: '.png'),
      title: '来自ByteCloud',
      description: 'image',
    ));
  }
}
