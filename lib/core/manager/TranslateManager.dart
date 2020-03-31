import 'dart:math';

import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/core/manager/DBManager.dart';
import 'package:bytes_cloud/core/manager/Manager.dart';
import 'package:bytes_cloud/entity/entitys.dart';
import 'package:bytes_cloud/model/ListModel.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

/// 文件上传和下载管理器
///
///

class TranslateManager extends Manager {
  List<DownloadTask> _downloads;
  List<DownloadTask> get downloads => _downloads;
  List<UploadTask> _uploads;
  List<UploadTask> get uploads => _uploads;

  static TranslateManager _manager;
  TranslateManager._init() {
    _downloads = [];
    _uploads = [];
    initFromDB().whenComplete(() {
      print('TranslateManager 初始化完成');
    });
  }

  static TranslateManager instant() {
    if (_manager == null) {
      _manager = TranslateManager._init();
    }
    return _manager;
  }

  @override
  initFromDB() async {
    List<Map> ds =
        await DBManager.instance.queryAll(DownloadTask.tableName, null);
    if (ds != null) {
      _downloads = ds.map((d) => DownloadTask.formMap(d)).toList();
    }
    List<Map> us =
        await DBManager.instance.queryAll(UploadTask.tableName, null);
    if (us != null) {
      _uploads = us.map((u) => UploadTask.formMap(u)).toList();
    }
  }

  // 目前只将完成的任务存入DB
  saveFinishedTask2DB(Task task) {
    if (task is UploadTask) {
      DBManager.instance.insert(UploadTask.tableName, task);
    } else if (task is DownloadTask) {
      DBManager.instance.insert(DownloadTask.tableName, task);
    }
  }

  @override
  destroy() {
    //_downloads
    //_uploads
    _manager = null;
  }
}

abstract class Task extends Entity {
  int uuid;
  // CancelToken token; // 任务id
  int time;
  int sent = 0;
  int total = 0;
  double v = 0; //速度
  double get progress {
    if (total == 0)
      return 0;
    else
      return sent / total;
  }

  Task({this.time}) : super.fromMap(null) {
    time = DateTime.now().millisecondsSinceEpoch;
    uuid = generateUUid(time);
  }

  generateUUid(int time) => (time - Random(time).nextInt(2000)).hashCode;

  String get name;
  String get pathMsg;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  @override
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'time': time,
      'sent': sent,
      'total': total,
    };
  }

  Task.fromMap(Map map) : super.fromMap(null) {
    this.uuid = map['uuid'];
    this.time = map['time'];
    this.uuid = generateUUid(this.time);
    this.sent = map['sent'];
    this.total = map['total'];
  }
}

class DownloadTask extends Task {
  static const String tableName = 'DownloadTask';
  static getSQL() => '''
            CREATE TABLE $tableName(
            uuid INTEGER PRIMARY KEY,
            id INTEGER, 
            filename TEXT, 
            path TEXT,
            time INTEGER, 
            sent INTEGER,
            total INTEGER)
  ''';
  int id;
  String filename;
  String path;

  DownloadTask(
      {@required this.id, @required this.filename, @required this.path})
      : super();

  @override
  String get name => FileUtil.getFileNameWithExt(filename);

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = super.toMap();
    result.addAll({
      'id': id,
      'filename': filename,
      'path': path,
    });
    return result;
  }

  DownloadTask.formMap(Map map) : super.fromMap(map) {
    this.id = map[id];
    this.filename = map['filename'];
    this.path = map['path'];
  }

  @override
  String get pathMsg => path.substring(0, path.length - filename.length);
}

class UploadTask extends Task {
  static const String tableName = 'UploadTask';
  static getSQL() => '''
            CREATE TABLE $tableName(
            uuid INTEGER PRIMARY KEY,
            pid INTEGER, 
            path TEXT, 
            time INTEGER, 
            sent INTEGER,
            total INTEGER)
  ''';

  int pid;
  String path; // 文件地址

  UploadTask({@required this.path, @required this.pid}) : super();

  @override
  String get name => FileUtil.getFileNameWithExt(path);

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = super.toMap();
    result.addAll({
      'pid': pid,
      'path': path,
    });
    return result;
  }

  UploadTask.formMap(Map map) : super.fromMap(map) {
    pid = map['pid'];
    path = map['path'];
  }

  @override
  String get pathMsg =>
      CloudFileManager.instance().getVitualPathById(pid) + '/';
}
