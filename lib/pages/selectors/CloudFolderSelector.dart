import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
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

  List<CloudFileEntity> currentFiles = [];
  List<CloudFileEntity> path = []; // 路径

  @override
  void initState() {
    super.initState();
    filePaths = widget.filePaths;
    path.add(CloudFileManager.instance().root);
  }

  enterFolderAndRefresh(int pid) =>
      setState(() => path.add(CloudFileManager.instance().getEntityById(pid)));

  bool outFolderAndRefresh() {
    if (path.length == 1) return true;
    setState(() {
      path.removeLast();
    });
    return false;
  }

  refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    currentFiles =
        CloudFileManager.instance().listFiles(path.last.id, justFolder: true);
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        title: Text('已选择 ${filePaths.length} 项'),
        actions: <Widget>[
          UI.appbarBtn(
            Icons.done,
            call: (context) async {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("开始上传")));
              Future.delayed(Duration(seconds: 1)).then((v) {
                Navigator.pop(context);
              });
              await CloudFileManager.instance()
                  .uploadFile(path.last.id, filePaths);
            },
          ),
        ],
      ),
      body: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              headerView(),
              Expanded(
                  child: WillPopScope(
                      onWillPop: () async => outFolderAndRefresh(),
                      child: bodyView())),
            ],
          )),
      floatingActionButton: Builder(
          builder: (BuildContext context) => FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () async => await newFolder(context),
              )),
    );
  }

  newFolder(BuildContext context) async {
    String folderName = await UI.showInputDialog(context, "创建文件夹");
    if (folderName == null) return;
    if (folderName.trim() == '') {
      UI.showSnackBar(context, Text('文件名为空'));
      return;
    }
    bool success = await CloudFileManager.instance()
        .newFolder(path.last.id, folderName.trim());
    if (success)
      refresh();
    else
      UI.showSnackBar(context, Text('创建文件夹失败'));
  }

  bodyView() {
    return ListView.separated(
      itemCount: currentFiles.length,
      itemBuilder: (BuildContext context, int index) {
        CloudFileEntity entity = currentFiles[index];
        return Padding(
            padding: EdgeInsets.only(left: 0, right: 0),
            child: UI.buildCloudFolderItem(
                file: entity,
                childrenCount: CloudFileManager.instance()
                    .childrenCount(entity.id, justFolder: true),
                onTap: () {
                  enterFolderAndRefresh(entity.id);
                }));
      },
      separatorBuilder: (BuildContext context, int index) {
        return UI.divider2(left: 72, right: 32);
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
