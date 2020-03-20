import 'dart:convert';

import 'package:bytes_cloud/core/manager/CloudFileLogic.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/http/http.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RemoteRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RemoteRouteState();
  }
}

class RemoteRouteState extends State<RemoteRoute>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<List<CloudFileEntity>> stack = []; // 实现目录结构
  CloudFileEntity parentDir; //当前的根目录
  List<CloudFileEntity> files = []; //当前目录的全部文件

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.widgets),
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.transform),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {},
          )
        ],
      ),
      body: FutureBuilder(
        future: CloudFileHandle.getAllFile(), // 请求数据，并存DB
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return handleGetCloudFiles();
          }
          return Center(child: Text('error'));
        },
      ),
    );
  }

  handleGetCloudFiles() {
    files = CloudFileManager.instance().listRootFiles();
    return ListView.builder(
        itemCount: files.length,
        itemBuilder: (BuildContext context, int index) {
          CloudFileEntity entity = files[index];
          if (entity.isFolder()) {
            return UI.buildCloudFolderItem(file: entity, onTap: () {});
          }
          return fileItemView(entity);
        });
  }

  fileItemView(CloudFileEntity entity) {
    return Text(entity.fileName);
  }

  folderItemView(CloudFileEntity entity) {
    return ListTile(
      leading: Image.asset(
        Constants.FOLDER,
        width: 24,
      ),
      title: Text(entity.fileName),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }
}
