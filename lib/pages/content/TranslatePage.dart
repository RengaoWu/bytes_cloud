import 'package:bytes_cloud/core/manager/TranslateManager.dart';
import 'package:bytes_cloud/model/ListModel.dart';
import 'package:bytes_cloud/model/ThemeModel.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/OtherUtil.dart';
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
//  回掉更新太快，导致频繁刷新，这里不使用Provider
//  TranslatePage._init();
//  static Widget newPage() {
//    return MultiProvider(
//      providers: <SingleChildWidget>[
//        ChangeNotifierProvider.value(
//                value: TranslateManager.instant().downloadTask),
//        ChangeNotifierProvider.value(
//                value: TranslateManager.instant().uploadTask),
//      ],
//      child: Consumer2<ListModel<DownloadTask>, ListModel<UploadTask>>(
//              builder: (context, downloads, uploads, child) {
//                return TranslatePage._init();
//              }),
//    );
//  }
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
