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
  int parentId; //当前的根目录
  List<CloudFileEntity> files = []; //当前目录的全部文件

  ListView listView;

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
        body: WillPopScope(
          child: listView != null
              ? handleGetCloudFiles(parentId)
              : FutureBuilder(
                  future: CloudFileHandle.reflashCloudFileList(), // 请求数据，并存DB
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      print('CloudFileHandle#getAllFile error! ');
                    }
                    return handleGetCloudFiles(
                        CloudFileManager.instance().rootId);
                  },
                ),
          onWillPop: () async {
            if (stack.isEmpty) {
              Navigator.pop(context);
            } else {
              files = stack.removeLast();
              setState(() {});
            }
            return false;
          },
        ));
  }

  handleGetCloudFiles(int pid) {
    parentId = pid;
    files = CloudFileManager.instance().listFiles(parentId);
    listView = ListView.builder(
        itemCount: files.length,
        itemBuilder: (BuildContext context, int index) {
          CloudFileEntity entity = files[index];
          if (entity.isFolder()) {
            return UI.buildCloudFolderItem(
                file: entity,
                onTap: () {
                  parentId = entity.id;
                  stack.add(files);
                  setState(() {});
                });
          }
          return UI.buildCloudFileItem(file: entity, onTap: () {});
        });
    return RefreshIndicator(
      child: listView,
      onRefresh: () async {
        await CloudFileHandle.reflashCloudFileList();
        setState(() {});
      },
    );
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
}
