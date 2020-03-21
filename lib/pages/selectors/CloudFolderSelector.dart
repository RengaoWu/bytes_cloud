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
  List<List<CloudFileEntity>> dirStack = []; //列表

  @override
  void initState() {
    super.initState();
    filePaths = widget.filePaths;
    enterFolder(CloudFileManager.instance().rootId);
  }

  enterFolderAndRefresh(int pid) => setState(() {
        enterFolder(pid);
      });

  enterFolder(int pid) {
    path.add(CloudFileManager.instance().getEntityById(pid));
    currentPageFolders =
        CloudFileManager.instance().listFiles(pid, justFolder: true);
    dirStack.add(currentPageFolders);
  }

  bool outFolderAndRefresh() {
    if (path.length == 1) return true;
    setState(() {
      path.removeLast();
      dirStack.removeLast();
      currentPageFolders = dirStack.last;
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        title: Text('已选择 ${filePaths.length} 项'),
        actions: <Widget>[
          UI.appbarBtn(
            Icons.done,
            call: (context) {
              filePaths.forEach((f) {
                CloudFileHandle.uploadOneFile(0, f);
              });
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("开始上传")));
              Future.delayed(Duration(seconds: 1)).then((v) {
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
      body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              headerView(),
              Expanded(
                  child: WillPopScope(
                      onWillPop: () async => outFolderAndRefresh(),
                      child: bodyView())),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          String folderName = await UI.showInputDialog(context, "创建文件夹");
          if (folderName.trim() == '') return;
          var rsp =
              await CloudFileHandle.newFolder(path.last.id, folderName.trim());
        },
      ),
    );
  }

  bodyView() {
    return ListView.separated(
      itemCount: currentPageFolders.length,
      itemBuilder: (BuildContext context, int index) {
        CloudFileEntity entity = currentPageFolders[index];
        return Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: UI.buildCloudFolderItem(
                file: entity,
                childrenCount: CloudFileManager.instance()
                    .childrenCount(entity.id, justFolder: true),
                onTap: () {
                  enterFolderAndRefresh(entity.id);
                }));
      },
      separatorBuilder: (BuildContext context, int index) {
        return UI.divider2(left: 80, right: 32);
      },
    );
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
