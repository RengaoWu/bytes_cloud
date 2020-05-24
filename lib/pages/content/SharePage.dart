import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/core/manager/DBManager.dart';
import 'package:bytes_cloud/core/manager/ShareManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/entity/ShareEntity.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SharePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SharePageState();
  }
}

class SharePageState extends State<SharePage> {
  List<ShareEntity> entities;
  List<CloudFileEntity> cloudFiles;
  GlobalKey qrCodeKey = new GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('分享'),
        leading: BackButton(),
      ),
      body: entities != null
          ? listView()
          : FutureBuilder<List<Map>>(
              future: DBManager.instance.queryAll(ShareEntity.tableName,
                  orderBy: ShareEntity.ORDER_BY_BEGIN_TIME_DESC),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  List<Map> data = snapshot.data as List<Map>;
                  List<ShareEntity> shares = [];
                  List<CloudFileEntity> files = [];
                  for (Map map in data) {
                    ShareEntity entity = ShareEntity.fromMap(map);
                    CloudFileEntity cloudFileEntity =
                        CloudFileManager.instance()
                            .getEntityById(entity.fileID);
                    if (cloudFileEntity != null) {
                      shares.add(entity);
                      files.add(cloudFileEntity);
                    }
                  }
                  entities = shares;
                  cloudFiles = files;
                  return listView();
                }
                return Center(
                  child: Text('空空如也!'),
                );
              },
            ),
    );
  }

  listView() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return listItem(context, cloudFiles[index], entities[index], qrCodeKey,
            () {
          setState(() {
            entities.remove(entities[index]);
            cloudFiles.remove(cloudFiles[index]);
          });
        });
      },
      addAutomaticKeepAlives: true,
      itemCount: entities.length,
    );
  }

  static Widget listItem(BuildContext context, CloudFileEntity cloudFileEntity,
      ShareEntity shareEntity, GlobalKey key, Function del,
      {bool needLeading = true}) {
    String subTitle;
    if (shareEntity.shareToken == null) {
      subTitle = '无需验证';
    } else {
      subTitle = '验证码: ${shareEntity.shareToken}';
    }
    subTitle += '    ';
    subTitle += UI.convertTimeToString(
        DateTime.fromMillisecondsSinceEpoch(shareEntity.endTime));
    return ListTile(
      leading: needLeading
          ? SizedBox(
              width: 80,
              child: UI.selectIcon(cloudFileEntity.fileName, true,
                  isUrl: true, id: cloudFileEntity.id, size: 80))
          : null,
      title: Text(
        cloudFileEntity.fileName,
        style: TextStyle(fontSize: 13),
      ),
      subtitle: Text(
        subTitle,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: InkWell(
        child: Icon(
          Icons.clear,
          size: 24,
        ),
        onTap: () async {
          bool success =
              await ShareManager.instance.deleteShareFile(shareEntity);
          if (success) del();
        },
      ),
      onTap: () {
        UI.showContentDialog(
            context,
            '分享文件',
            RepaintBoundary(
                key: key,
                child: Column(
                  children: <Widget>[
                    boldText(cloudFileEntity.fileName),
                    QrImage(
                      // 分享的链接不加token
                      data: shareEntity.getShareDownloadURLWithoutToken,
                    ),
                    Text(
                      '来自ByteCloud',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                )),
            left: '复制链接',
            leftCall: () {
              Clipboard.setData(
                  ClipboardData(text: shareEntity.getShareContent));
              Fluttertoast.showToast(msg: '复制到剪切板');
            },
            right: '保存二维码',
            rightCall: () async {
              await FileUtil.saveUI2Image(key);
            });
      },
    );
  }
}
