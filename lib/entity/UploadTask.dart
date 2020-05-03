import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/entity/TranslateTask.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:flutter/material.dart';

class UploadTask extends TranslateTask {
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

  @override
  String get filePath => path;
}
