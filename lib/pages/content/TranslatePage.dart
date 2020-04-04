import 'package:bytes_cloud/core/manager/TranslateManager.dart';
import 'package:bytes_cloud/model/ListModel.dart';
import 'package:bytes_cloud/model/ThemeModel.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/ThumbUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class TranslatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TranslatePageState();
  }
}

class TranslatePageState extends State<TranslatePage>
    with SingleTickerProviderStateMixin {
  static const List<String> tabs = [
    '下载列表',
    '上传列表',
  ];
  TabController controller;
  TranslateManager translateManager;
  List<DownloadTask> downloads;
  List<UploadTask> uploads;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: tabs.length, vsync: this);
    translateManager = TranslateManager.instant();
    downloads = TranslateManager.instant().downloads;
    uploads = TranslateManager.instant().uploads;
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 1000)).whenComplete((() {
      if (mounted) setState(() {});
    }));
    print('TranslatePageState build');
    return Scaffold(
      appBar: AppBar(
        title: Text('传输列表'),
        bottom: TabBar(
          controller: controller,
          tabs: tabs.map((t) {
            return Tab(
              text: t,
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
          controller: controller,
          children: tabs.map((t) {
            return _taskListView(t);
          }).toList()),
    );
  }

  Widget _taskListView(String t) {
    List<Task> tasks;
    if (tabs[0] == t) {
      tasks = downloads;
    } else {
      tasks = uploads;
    }
    return ListView.separated(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        return _taskItemView(tasks[index]);
      },
      separatorBuilder: (BuildContext context, int index) => Divider(
        indent: 16,
        endIndent: 16,
      ),
    );
  }

  Widget _taskItemView(Task task) {
    Widget trailing;
    Widget subTitle;
    if (task.progress == 1) {
      trailing = Icon(Icons.done);
      subTitle = Text(
        UI.convertTimeToString(DateTime.fromMillisecondsSinceEpoch(task.time)) +
            '    ' +
            task.pathMsg,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    } else {
      trailing = Text(
        '${FileUtil.getFileSize(task.v?.toInt())} / s',
        style: TextStyle(fontSize: 13),
      );
      subTitle = LinearProgressIndicator(
        value: task.progress,
      );
    }
    return ListTile(
      leading: UI.selectIcon(task.name, false, size: 40),
      title: Text(
        task.name,
        style: TextStyle(fontSize: 14),
      ),
      subtitle: subTitle,
      trailing: trailing,
    );
//    return Card(
//      child: Stack(
//        alignment: Alignment.center,
//        children: <Widget>[
//          Positioned(
//            child: UI.selectIcon(task.name, false, size: 24),
//            left: 8,
//            top: 8,
//          ),
//          Positioned(
//              top: 24,
//              child: SizedBox(
//                  width: 100,
//                  height: 100,
//                  child: Stack(alignment: Alignment.center, children: <Widget>[
//                    SizedBox(
//                        width: 100,
//                        height: 100,
//                        child: CircularProgressIndicator(
//                          value: task.progress,
//                          valueColor: AlwaysStoppedAnimation(Colors.green),
//                        )),
//                    Positioned(
//                      child: Text(content),
//                    ),
//                  ]))),
//          Positioned(
//            child: Text(task.name.length > 20
//                ? task.name.substring(0, 17) + '...'
//                : task.name),
//            bottom: 24,
//          ),
//          Positioned(
//            bottom: 8,
//            left: 8,
//            child: Text(
//              convertTimeToString(
//                  DateTime.fromMillisecondsSinceEpoch(task.time)),
//              style: TextStyle(color: Colors.grey, fontSize: 10),
//            ),
//          )
//        ],
//      ),
//    );
  }
}
