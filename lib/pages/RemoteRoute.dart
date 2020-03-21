import 'dart:convert';

import 'package:bytes_cloud/core/manager/CloudFileLogic.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
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
  List<CloudFileEntity> currentFiles = [];
  List<CloudFileEntity> path = []; // 路径

  @override
  void initState() {
    super.initState();
    enterFolder(CloudFileManager.instance().rootId);
  }

  enterFolderAndRefresh(int pid) => setState(() {
        enterFolder(pid);
      });

  enterFolder(int pid) {
    path.add(CloudFileManager.instance().getEntityById(pid));
    currentFiles = CloudFileManager.instance().listFiles(pid);
  }

  bool outFolderAndRefresh() {
    if (path.length == 1) return true;
    setState(() {
      path.removeLast();
      currentFiles = CloudFileManager.instance()
          .listFiles(path.last.id, justFolder: false);
    });
    return false;
  }

  refreshList() {
    setState(() {
      currentFiles = CloudFileManager.instance()
          .listFiles(path.last.id, justFolder: false);
    });
  }

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
            Builder(
                builder: (context) => IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => newFolder(context))),
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
          child: cloudListView(),
          onWillPop: () async => outFolderAndRefresh(),
        ));
  }

  cloudListView() {
    var listView = ListView.separated(
        itemCount: currentFiles.length,
        separatorBuilder: (BuildContext context, int index) {
          return UI.divider2(left: 80, right: 32);
        },
        itemBuilder: (BuildContext context, int index) {
          CloudFileEntity entity = currentFiles[index];
          Widget item;
          if (entity.isFolder()) {
            item = UI.buildCloudFolderItem(
                file: entity,
                childrenCount:
                    CloudFileManager.instance().childrenCount(entity.id),
                onTap: () {
                  enterFolderAndRefresh(entity.id);
                });
          } else {
            item = UI.buildCloudFileItem(file: entity, onTap: () {});
          }
          return Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: item,
          );
        });
    return RefreshIndicator(
      child: Scrollbar(child: listView),
      onRefresh: () async {
        await CloudFileHandle.reflashCloudFileList();
        currentFiles = CloudFileManager.instance().listFiles(path.last.id);
        setState(() {});
      },
    );
  }

  newFolder(BuildContext context) async {
    String folderName = await UI.showInputDialog(context, "创建文件夹");
    if (folderName.trim() == '') {
      UI.showSnackBar(context, '文件名为空');
      return;
    }
    await CloudFileHandle.newFolder(path.last.id, folderName.trim(),
        successCall: (_) => refreshList(),
        failedCall: (Map<String, dynamic> rsp) {
          UI.showSnackBar(context, rsp['message']);
        });
  }

  @override
  bool get wantKeepAlive => true;
}
