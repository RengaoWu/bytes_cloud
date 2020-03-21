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
    '下载历史',
    '上传列表',
  ];
  TabController controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
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
            return Text(t);
          }).toList()),
    );
  }
}
