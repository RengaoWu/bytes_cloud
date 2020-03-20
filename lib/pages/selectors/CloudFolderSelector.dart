import 'package:bytes_cloud/core/manager/CloudFileLogic.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CloudFolderSelector extends StatefulWidget {
  final List<String> filePaths;
  CloudFolderSelector(this.filePaths);
  @override
  State<StatefulWidget> createState() {
    return _CloudFolderSelectorState();
  }
}

class _CloudFolderSelectorState extends State<CloudFolderSelector> {
  List<String> filePaths;

  List<CloudFileEntity> currentPageFolders = [];
  List<CloudFileEntity> path = []; // 路径
  List<List<CloudFileEntity>> dirList = []; //列表

  @override
  void initState() {
    super.initState();
    filePaths = widget.filePaths;
    path.add(CloudFileManager.instance()
        .getEntityById(CloudFileManager.instance().rootId));
    currentPageFolders =
        CloudFileManager.instance().listRootFiles(justFolder: true);
    dirList.add(currentPageFolders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('已选择 ${filePaths.length} 项'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              filePaths.forEach((f) {
                CloudFileHandle.uploadOneFile(0, f);
              });
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("开始上传")));
            },
          )
        ],
      ),
      body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              headerView(),
              Expanded(child: bodyView()),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          String folderName = await UI.showInputDialog(context, "创建文件夹");
          if (folderName.trim() == '') return;
          CloudFileHandle.newFolder(path.last.id, folderName.trim());
        },
      ),
    );
  }

  bodyView() {
    return ListView.builder(
        itemCount: currentPageFolders.length,
        itemBuilder: (BuildContext context, int index) {
          CloudFileEntity entity = currentPageFolders[index];
          return UI.buildCloudFolderItem(
              file: entity,
              onTap: () {
                setState(() {
                  currentPageFolders = CloudFileManager.instance()
                      .listFiles(entity.id, justFolder: true);
                  dirList.add(currentPageFolders);
                  path.add(entity);
                });
              });
        });
  }

  headerView() {
    int i = 0;
    List<Widget> widgets = path.map((p) {
      i++;
      FontWeight fontWeight =
          i == path.length ? FontWeight.bold : FontWeight.normal;
      if (p.id == 0) {
        return boldText('云盘 > ', fontSize: 16, fontWeight: fontWeight);
      }
      return boldText(p.fileName + ' > ', fontSize: 16, fontWeight: fontWeight);
    }).toList();
    return Row(
      children: widgets,
    );
  }
}
