import 'dart:math';

import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:flutter/cupertino.dart';

/// 文件上传和下载管理器
///
///

class TranslateManager {
  static TranslateManager _manager;
  TranslateManager._init() {
    // todo 在 main 中初始化
    // todo 读取数据库，初始化列表
  }
  static TranslateManager instant() {
    if (_manager == null) {
      _manager = TranslateManager._init();
    }
    return _manager;
  }

  List<DownloadTask> _doingTasks = [];
  List<DownloadTask> get doingTasks => _doingTasks;
  List<UploadTask> _downTasks = [];
  List<UploadTask> get downTasks => _downTasks;

  void addDoingTask(Task task) {
    _doingTasks.add(task);
  }

  void addDownTask(Task task) {
    _downTasks.add(task);
  }
}

abstract class Task {
  int token; // 任务id
  int time;
  int sent = 0;
  int total = 0;
  double get progress => sent / total;
  double v; //速度

  Task() {
    time = DateTime.now().millisecondsSinceEpoch;
    token = time.hashCode + name.hashCode;
  }

  String get name;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && token == other.token;

  @override
  int get hashCode => token.hashCode;
}

class DownloadTask extends Task {
  int id;
  String fileName;
  String path;

  DownloadTask(
      {@required this.id, @required this.fileName, @required this.path})
      : super();

  @override
  String get name => FileUtil.getFileNameWithExt(fileName); // 下载地址
}

class UploadTask extends Task {
  UploadTask({@required this.path}) : super();
  String path; // 文件地址

  @override
  String get name => FileUtil.getFileNameWithExt(path); // 下载地址

}
