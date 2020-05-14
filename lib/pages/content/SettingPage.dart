import 'dart:io';

import 'package:bytes_cloud/core/Common.dart';
import 'package:bytes_cloud/core/StaticConfig.dart';
import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/model/ThemeModel.dart';
import 'package:bytes_cloud/utils/IoslateMethods.dart';
import 'package:bytes_cloud/utils/SPUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
        children: <Widget>[
          themeSetting(context),
          divider(),
          switchSetting('微信文件自动上传', Common.instance.wxAutoSync, (value) async {
            Common.instance.wxAutoSync = value;
            SP.setBool(SP.KEY_SYNC_WX, value);
            if (value) {
              syncFile(StaticConfig.FOLDER_AUTO_SYNC_WX,
                  [Common.instance.sWxMsg, Common.instance.sWxDirDownload]);
            }
          }),
          switchSetting('QQ文件自动上传', Common.instance.qqAutoSync, (value) async {
            SP.setBool(SP.KEY_SYNC_QQ, value);
            Common.instance.qqAutoSync = value;
            if (value) {
              syncFile(StaticConfig.FOLDER_AUTO_SYNC_QQ,
                  [Common.instance.sQQFileRecDir]);
            }
          }),
          switchSetting('相册文件自动上传', Common.instance.imageAutoSync,
              (value) async {
            SP.setBool(SP.KEY_SYNC_IMAGE, value);
            Common.instance.imageAutoSync = value;
            if (value) {
              syncFile(
                  StaticConfig.FOLDER_AUTO_SYNC_IMAGE, [Common.instance.DCIM]);
            }
          }),
          divider(),
          switchSetting('使用数据流量上传/下载', Common.instance.translateInGPRS,
              (value) {
            SP.setBool(SP.KEY_TRANSLATE_ONLY_IN_GPRS, value);
            Common.instance.translateInGPRS = value;
          }),
          ListTile(
            title: Text('下载保存地址'),
            subtitle: Text(Common.instance.appDownload),
          ),
          switchSetting('显示隐藏文件', Common.instance.showHiddenFile, (value) {
            SP.setBool(SP.KEY_SHOW_HIDDEN_FILE, value);
            Common.instance.showHiddenFile = value;
          }),
          divider(),
          ListTile(
            title: Text('清空缓存文件'),
            onTap: () {
              UI.showContentDialog(context, '清空缓存', Text('你确定清空缓存吗？'),
                  left: '取消',
                  leftCall: () {
                    Navigator.pop(context);
                  },
                  right: '确定',
                  rightCall: () {
                    UI.showProgressDialog(context: context);
                    // todo 删除Cache目录下的文件。
                    Future.delayed(Duration(seconds: 1)).whenComplete(() {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Fluttertoast.showToast(msg: '已经清空缓存');
                    });
                  });
            },
          ),
          ListTile(
            title: Text('关于'),
          )
        ],
      ),
    );
  }

  syncFile(String folder, List<String> roots) async {
    List<FileSystemEntity> result = await computeGetAllFiles(
        roots: roots, keys: StaticConfig.recentFileExt(), isExt: true);
    CloudFileEntity entity =
        CloudFileManager.instance().getCloudFileEntityByName(folder);
    if (entity == null) {
      entity = await CloudFileManager.instance()
          .newFolder(CloudFileManager.instance().root.id, folder);
    }
    CloudFileManager.instance().uploadFileWrapper(entity.id, result);
  }

  Widget switchSetting(String title, bool value, Function onChange) {
    return ListTile(
        title: Text(title),
        trailing: Switch(
            value: value,
            onChanged: (value) {
              onChange(value);
              setState(() {});
            }));
  }

  themeSetting(context) {
    return Column(
      children: <Widget>[
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
      ],
    );
  }

  divider() => Divider(
        indent: 8,
        endIndent: 8,
      );
}
