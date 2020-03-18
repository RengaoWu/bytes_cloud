import 'dart:io';

import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/OtherUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MarkDownListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MarkDownListPageState();
  }
}

class MarkDownListPageState extends State<MarkDownListPage> {
  List<FileSystemEntity> files;

  @override
  void initState() {
    super.initState();
    initFileList();
  }

  initFileList() {
    Future.wait([FileUtil.listFiles("notebook")]).then((value) {
      setState(() {
        files = value[0].cast<FileSystemEntity>();
      });
    });
  }

  Future<String> showInputDialog() async {
    TextEditingController _controller = TextEditingController();
    return showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('创建文件'),
            //可滑动
            content: TextField(
              controller: _controller,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () {
                  Navigator.pop(context, _controller.value.text);
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // initFileList(); // resume 刷新列表, 错误的做法会导致列表不停的刷新
    return Scaffold(
      appBar: AppBar(
        title: Text("笔记"),
      ),
      body: StaggeredGridView.countBuilder(
        crossAxisCount: 4,
        itemCount: files.length,
        staggeredTileBuilder: (index) => new StaggeredTile.fit(2),
        itemBuilder: (BuildContext context, int index) {
          return inkwellItemCard(files[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.title),
        onPressed: () {
          Future.wait([showInputDialog()]).then((onValue) {
            Future.wait([FileUtil.createFile('notebook', onValue[0], '.md')])
                .then((onValue) {
              if (onValue[0] == null) return;
              setState(() => files.add(onValue[0]));
            });
          });
        },
      ),
    );
  }

  inkwellItemCard(FileSystemEntity file) {
    String name = FileUtil.getFileName(file.path);
    String time = convertTimeToString(file.statSync().changed);
    return InkWell(
      child: itemCard(name, time, () {
        FileUtil.deleteFile(file.path);
        files.remove(file);
        setState(() {});
      }),
      onTap: () => UI.openFile(context, file),
    );
  }

  itemCard(String name, String time, Function del) {
    return Card(
      elevation: 4,
      child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                name,
                style: TextStyle(fontSize: 14),
              ),
              Divider(),
              Row(
                children: <Widget>[
                  Text(
                    time,
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            child: Icon(
                              Icons.delete_outline,
                              size: 16,
                            ),
                            onDoubleTap: del,
                          )))
                ],
              ),
            ],
          )),
    );
  }
}
