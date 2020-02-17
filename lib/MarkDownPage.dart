import 'dart:io';

import 'package:bytes_cloud/utils/FileUtils.dart';
import 'package:bytes_cloud/utils/WidgetUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
    Future.wait([FileUtils.listFiles("notebook")]).then((value) {
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
                  print("MarkDownPage 确定");
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
    return Scaffold(
      appBar: AppBar(
        title: Text("笔记"),
      ),
      body: ListView.separated(
          itemCount: files == null ? 0 : files.length,
          separatorBuilder: (BuildContext context, int index) {
            return WidgetUtils.getDivider(padding: 8);
          },
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: InkWell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(FileUtils.getFileName(files[index].path)),
                    Text("2018年12月12日"),
                  ],
                ),
                onTap: () => Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) =>
                            new MarkDownPage(files[index].path))),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.title),
        onPressed: () {
          Future.wait([showInputDialog()]).then((onValue) {
            if (onValue[0] == null) return;
            FileUtils.createFile('notebook', onValue[0]);
            Future.wait([FileUtils.listFiles('notebook')]).then((onValue) => {
                  setState(() {
                    files = onValue[0];
                  })
                });
          });
        },
      ),
    );
  }
}

class MarkDownPage extends StatefulWidget {
  String title;

  MarkDownPage(this.title) {}
  @override
  State<StatefulWidget> createState() {
    return MarkDownPageState(title);
  }
}

class MarkDownPageState extends State<MarkDownPage> {
  bool read = true;
  String filePath;
  String fileName;
  String testMDString;
  TextEditingController controller = TextEditingController();
  MarkDownPageState(this.filePath) {
    fileName = FileUtils.getFileName(filePath);
  }
  @override
  void initState() {
    super.initState();
    Future.wait([FileUtils.readFromFile(filePath)]).then((onValue) {
      setState(() {
        testMDString = onValue[0];
        controller.text = testMDString;
      });
    });
  }

  void showDeleteDialog() {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('删除文件'),
            //可滑动
            content: Text("你确定删除$fileName文件吗?"),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void showShareDialog() {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('分享文件'),
            //可滑动
            content: Text("http://hhhhhh.txt"),
            actions: <Widget>[
              new FlatButton(
                child: new Text('复制URL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void saveFile() {
    FileUtils.writeToFile(path: filePath, content: controller.value.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.fileName),
        actions: <Widget>[
          getAppbarBtn(Icons.delete_outline, showDeleteDialog),
          getAppbarBtn(Icons.share, showShareDialog),
          getAppbarBtn(Icons.save, saveFile)
        ],
      ),
      body: read
          ? Markdown(data: testMDString)
          : SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: TextField(
                    decoration: InputDecoration(border: null),
                    minLines: 50,
                    onChanged: (text) => testMDString = text,
                    maxLines: 100,
                    controller: controller,
                  ))),
      floatingActionButton: FloatingActionButton(
        child: read ? Icon(Icons.edit) : Icon(Icons.chrome_reader_mode),
        onPressed: () {
          setState(() {
            read = !read;
          });
        },
      ),
    );
  }

  Widget getAppbarBtn(IconData icon, void call()) {
    return Padding(
        padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: IconButton(
          onPressed: () {
            call();
          },
          icon: new Icon(icon),
        ));
  }
}
