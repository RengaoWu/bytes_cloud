import 'dart:io';

import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:bytes_cloud/widgets/Widgets.dart';
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
    initFileList(); // resume 刷新列表
    return Scaffold(
      appBar: AppBar(
        title: Text("笔记"),
      ),
      body: ListView.separated(
          itemCount: files == null ? 0 : files.length,
          separatorBuilder: (BuildContext context, int index) {
            return UI.divider(padding: 8);
          },
          itemBuilder: (BuildContext context, int index) {
            return BaseListItem(
              title: FileUtil.getFileName(files[index].path),
              subTitle: "2018年12月12日",
              hiddenBtnMsg: '删除文件',
              click: () => UI.newPage(context, MarkDownPage(files[index].path)),
              longPress: () {},
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.title),
        onPressed: () {
          Future.wait([showInputDialog()]).then((onValue) {
            if (onValue[0] == null) return;
            FileUtil.createFile('notebook', onValue[0]);
            Future.wait([FileUtil.listFiles('notebook')]).then((onValue) => {
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
  String testMDString = "";
  TextEditingController controller = TextEditingController();
  MarkDownPageState(this.filePath) {
    fileName = FileUtil.getFileName(filePath);
  }
  @override
  void initState() {
    super.initState();
    Future.wait([FileUtil.readFromFile(filePath)]).then((onValue) {
      setState(() {
        testMDString = onValue[0];
        controller.text = testMDString;
      });
    });
  }

  void saveFile() {
    FileUtil.writeToFile(path: filePath, content: controller.value.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.fileName),
        actions: <Widget>[
          UI.appbarBtn(Icons.delete_outline,
              call: (context) => UI.showMessageDialog(
                      context: context,
                      title: '删除',
                      content: Text('你确定删除$fileName文件吗?'),
                      map: {
                        '确定': () {
                          FileUtil.deleteFile(filePath);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        '取消': () {
                          Navigator.of(context).pop();
                        }
                      })),
          UI.appbarBtn(Icons.share,
              call: (context) => UI.showMessageDialog(
                      context: context,
                      title: '分享',
                      content: Text('fileName'),
                      map: {
                        '复制URL': () => {print('已复制')}
                      })),
          UI.appbarBtn(Icons.save, call: (context) {
            saveFile();
            Scaffold.of(context).showSnackBar(SnackBar(content: Text("保存成功")));
          } //Builder extends StatelessWidget
              )
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
}
