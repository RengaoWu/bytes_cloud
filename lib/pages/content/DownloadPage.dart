import 'package:bytes_cloud/core/manager/TranslateManager.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/OtherUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DownloadPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DownloadPageState();
  }
}

class DownloadPageState extends State<DownloadPage>
    with SingleTickerProviderStateMixin {
  static const List<String> tabs = [
    '正在传输',
    '已完成',
  ];
  TabController controller;
  List<DownloadTask> _doingTasks;
  List<UploadTask> _downTasks;
  TranslateManager translateManager;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: tabs.length, vsync: this);
    translateManager = TranslateManager.instant();
    _doingTasks = translateManager.doingTasks;
    _downTasks = translateManager.downTasks;
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1)).then((_) {
      setState(() {});
    });
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
            return tabs.indexOf(t) == 0
                ? _taskListView(_doingTasks)
                : _taskListView(_downTasks);
          }).toList()),
    );
  }

  Widget _taskListView(List<Task> tasks) {
    return GridView.builder(
        itemCount: tasks.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 8.0, childAspectRatio: 1.0),
        itemBuilder: (BuildContext context, int index) {
          return _taskItemView(tasks[index]);
        });
  }

  Widget _taskItemView(Task task) {
//    double progress = task.progress;
//    String fileName = task.name;
//    int time = task.time;
//    double v = task.v;
    String content;
    if (task.progress == 1) {
      content = '已完成';
    } else {
      content = '${FileUtil.getFileSize(task.v?.toInt())} / s';
    }
    return Card(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            child: UI.selectIcon(task.name, false, size: 24),
            left: 8,
            top: 8,
          ),
          Positioned(
              top: 24,
              child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(alignment: Alignment.center, children: <Widget>[
                    SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: task.progress,
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                        )),
                    Positioned(
                      child: Text(content),
                    ),
                  ]))),
          Positioned(
            child: Text(task.name.length > 20
                ? task.name.substring(0, 17) + '...'
                : task.name),
            bottom: 24,
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Text(
              convertTimeToString(
                  DateTime.fromMillisecondsSinceEpoch(task.time)),
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          )
        ],
      ),
    );
  }
}
