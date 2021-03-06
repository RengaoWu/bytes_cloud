import 'dart:io';

import 'package:bytes_cloud/core/manager/TranslateManager.dart';
import 'package:bytes_cloud/entity/DownloadTask.dart';
import 'package:bytes_cloud/entity/TranslateTask.dart';
import 'package:bytes_cloud/entity/UploadTask.dart';
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
    print('TranslatePageState build');
    Future.delayed(Duration(milliseconds: 1000)).whenComplete((() {
      if (mounted) setState(() {});
    }));
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
    List<TranslateTask> tasks;
    if (tabs[0] == t) {
      tasks = downloads;
    } else {
      tasks = uploads;
    }
    return ListView.separated(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        return TaskItem(tasks[index]);
      },
      separatorBuilder: (BuildContext context, int index) => Divider(
        indent: 16,
        endIndent: 16,
      ),
    );
  }
}

class TaskItem extends StatefulWidget {
  final TranslateTask task;
  TaskItem(this.task);
  @override
  State<StatefulWidget> createState() {
    return TaskItemState();
  }
}

class TaskItemState extends State<TaskItem> {
  TranslateTask task;
  Widget leading;
  @override
  void initState() {
    super.initState();
    task = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return _taskItemView(task);
  }

  Widget _taskItemView(TranslateTask task) {
    Future.delayed(Duration(milliseconds: 1000)).whenComplete((() {
      if (mounted) setState(() {});
    }));

    Widget trailing;
    Widget subTitle;
    if (task.progress == 1) {
      trailing = Icon(Icons.done);
      subTitle = Text(
        UI.convertTimeToString(DateTime.fromMillisecondsSinceEpoch(task.time)) +
            '    ' +
            task.pathMsg,
        style: TextStyle(fontSize: 10, color: Colors.grey),
      );
    } else {
      trailing = Text(
        '${FileUtil.getFileSize(task.v?.toInt(), fractionDigits: 0)}/s',
        style: TextStyle(fontSize: 12, ), textAlign: TextAlign.center,
      );
      subTitle = Container(
        child: LinearProgressIndicator(
          value: task.progress,
        ),
        width: 100,
      );
    }
    if (leading == null) {
      leading = UI.selectIcon(task.filePath, task.progress == 1, size: 40);
    }
    return ListTile(
      leading: SizedBox(child: leading, width: 50, height: 50,),
      title: Text(
        task.name,
        style: TextStyle(fontSize: 14),
      ),
      subtitle: subTitle,
      trailing: SizedBox(
        child: trailing,
        width: 60,
      ),
      onTap: () {
        if (task.progress == 1 && File(task.filePath).existsSync()) {
          UI.openFile(context, File(task.filePath));
        }
      },
    );
  }
}
