import 'dart:io';

import 'package:bytes_cloud/core/http/http.dart';
import 'package:bytes_cloud/core/manager/DBManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/entity/ShareEntity.dart';
import 'package:bytes_cloud/pages/content/SharePage.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MoreInfoPage extends StatefulWidget {
  CloudFileEntity entity;
  MoreInfoPage(this.entity);
  @override
  @override
  State<StatefulWidget> createState() {
    return MoreInfoPageState();
  }
}

class MoreInfoPageState extends State<MoreInfoPage> {
  CloudFileEntity entity;
  List<ShareEntity> shares;
  Widget icon;

  @override
  void initState() {
    super.initState();
    entity = widget.entity;
    if (FileUtil.isImage(entity.fileName)) {
      icon = Image.network(
        getPreviewUrl(entity.id, UI.dpi2px(200), UI.dpi2px(200)),
        height: 200,
        width: UI.DISPLAY_WIDTH,
        fit: BoxFit.cover,
      );
    } else {
      icon = UI.selectIcon(entity.fileName, true, size: 60);
    }
    if (FileUtil.haveDownloaded(entity)) {
      icon = InkWell(
        child: icon,
        onTap: UI.openFile(context, File(FileUtil.getDownloadFilePath(entity))),
      );
    }
    entity = widget.entity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(
          entity.fileName,
          style: TextStyle(fontSize: 14),
        ),
      ),
      body: shares == null
          ? FutureBuilder<List<ShareEntity>>(
              future: getShares(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox();
                }
                shares = snapshot.data;
                return body();
              },
            )
          : body(),
    );
  }

  body() {
    String downloadInfo = FileUtil.haveDownloaded(entity)
        ? FileUtil.getDownloadFilePath(entity)
        : '未下载';

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        int realIndex = index - 5;
        if(index == 0) return Padding(
          child: icon,
          padding: EdgeInsets.only(top: 8),
        );
        if(index == 1) return titleAndContent(
            '上传日期：',
            UI.convertTimeToString(
                DateTime.fromMillisecondsSinceEpoch(entity.uploadTime)));
        if(index == 2) return titleAndContent('云盘中的位置：', entity.pathRoot);
        if(index == 3) return titleAndContent('下载的位置：', downloadInfo);
        if(index == 4) return titleAndContent('分享记录', '');
        return SharePageState.listItem(context, entity, shares[realIndex], GlobalKey(), () {
          shares.removeAt(realIndex);
          setState(() {});
        }, needLeading: false);
      },
      addAutomaticKeepAlives: true,
      itemCount: shares.length + 5,
    );
  }

  Future<List<ShareEntity>> getShares() async {
    List map = await DBManager.instance.queryAll(ShareEntity.tableName,
        where: 'file_id = ?', args: [entity.id], orderBy: ShareEntity.ORDER_BY_END_TIME_DESC);
    List<ShareEntity> shares = map.map((m) {
      return ShareEntity.fromMap(m);
    }).toList();
    return shares;
  }

  Widget titleAndContent(String title, String content) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(content),
        ],
      ),
    );
  }
}
