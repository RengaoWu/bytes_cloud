import 'dart:io';

import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MarkDownPage extends StatefulWidget {
  final Map<String, dynamic> args;

  MarkDownPage(this.args);
  @override
  State<StatefulWidget> createState() {
    return MarkDownPageState(args);
  }
}

class MarkDownPageState extends State<MarkDownPage> {
  bool read = true;
  String path;
  String name;
  String txt = "";
  Map<String, dynamic> args;
  TextEditingController controller = TextEditingController();
  MarkDownPageState(this.args) {
    path = args['path'];
    name = FileUtil.getFileName(path);
  }
  @override
  void initState() {
    super.initState();
    Future.wait([FileUtil.readFromFile(path)]).then((onValue) {
      setState(() {
        txt = onValue[0];
        controller.text = txt;
      });
    });
  }

  void saveFile() {
    FileUtil.writeToFile(path: path, content: controller.value.text);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: InkWell(
            child: Text(this.name),
            onTap: () async {
              String newName = await UI.showInputDialog(context, '重命名');
              if (newName != null) {
                File file = new File(path).renameSync(
                    FileUtil.getFilePathWithoutName(path) +
                        '/' +
                        newName +
                        '.md');
                setState(() {
                  path = file.path;
                  name = newName;
                });
              }
            },
          ),
          actions: <Widget>[
            UI.appbarBtn(Icons.delete_outline,
                call: (context) => UI.showMessageDialog(
                        context: context,
                        title: '删除',
                        content: Text('你确定删除$name文件吗?'),
                        map: {
                          '确定': () {
                            FileUtil.deleteFile(path);
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
                        title: '分享笔记：$name',
                        content: Text(txt.length > 100
                            ? txt.substring(0, 100) + '...'
                            : txt),
                        map: {
                          '复制URL': () {
                            Fluttertoast.showToast(msg: '复制成功');
                            Navigator.pop(context);
                          }
                        })),
            UI.appbarBtn(Icons.save, call: (context) {
              saveFile();
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("保存成功")));
            } //Builder extends StatelessWidget
                )
          ],
        ),
        body: read
            ? Markdown(data: txt)
            : SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: TextField(
                      decoration: InputDecoration(border: null),
                      minLines: 50,
                      onChanged: (text) => txt = text,
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
      ),
      onWillPop: () async {
        saveFile();
        return true;
      },
    );
  }
}
