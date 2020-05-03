import 'package:bytes_cloud/entity/TranslateTask.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:flutter/material.dart';

class DownloadTask extends TranslateTask {
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

  @override
  String get filePath => path;
}
