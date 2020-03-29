import 'package:bytes_cloud/core/manager/TranslateManager.dart';
import 'package:bytes_cloud/model/ListModel.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/OtherUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    controller = TabController(length: tabs.length, vsync: this);
    translateManager = TranslateManager.instant();
  }

  @override
  Widget build(BuildContext context) {
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
            return tabs.indexOf(t) == 0
                ? ListenableProvider.value(
                    child: _taskListView(t),
                    value: translateManager.downloadTask,
                  )
                : ListenableProvider.value(
                    child: _taskListView(t),
                    value: translateManager.uploadTask,
                  );
          }).toList()),
    );
  }

  Widget _taskListView(String t) {
    List<Task> tasks;
    if (tabs[0] == t) {
      tasks = Provider.of<ListModel<DownloadTask>>(context).list;
    } else {
      tasks = Provider.of<ListModel<UploadTask>>(context).list;
    }
    return GridView.builder(
        itemCount: tasks.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 8.0, childAspectRatio: 1.0),
        itemBuilder: (BuildContext context, int index) {
          return _taskItemView(tasks[index]);
        });
  }

  Widget _taskItemView(Task task) {
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
