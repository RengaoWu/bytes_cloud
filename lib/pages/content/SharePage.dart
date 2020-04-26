import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/core/manager/DBManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/entity/ShareEntity.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SharePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SharePageState();
  }
}

class SharePageState extends State<SharePage> {
  List<ShareEntity> entities;
  List<CloudFileEntity> cloudFiles;
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
              future: DBManager.instance.queryAll(
                  ShareEntity.tableName, ShareEntity.ORDER_BY_BEGIN_TIME),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  entities = (snapshot.data as List<Map>).map((m) {
                    return ShareEntity.fromMap(m);
                  }).toList();
                  cloudFiles = entities.map((f) {
                    return CloudFileManager.instance().getEntityById(f.fileID);
                  }).toList();
                  return listView();
                }
                return Center(
                  child: Text('Ops!'),
                );
              },
            ),
    );
  }

  listView() {
    return ListView.builder(
      itemBuilder: (context, index) {
        CloudFileEntity cloudFileEntity = cloudFiles[index];
        ShareEntity shareEntity = entities[index];
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
          leading: SizedBox(
              width: 80,
              child: UI.selectIcon(cloudFileEntity.fileName, true,
                  isUrl: true, id: cloudFileEntity.id, size: 80)),
          title: Text(
            cloudFiles[index].fileName,
            style: TextStyle(fontSize: 13),
          ),
          subtitle: Text(
            subTitle,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: InkWell(
            child: Icon(
              Icons.clear,
              size: 16,
            ),
            onTap: () async {
              bool success = await CloudFileManager.instance()
                  .deleteShareFile(shareEntity);
              if (success)
                setState(() {
                  entities.remove(shareEntity);
                  cloudFiles.remove(cloudFileEntity);
                });
            },
          ),
        );
      },
      itemCount: entities.length,
    );
  }
}
