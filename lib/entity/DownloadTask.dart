import 'package:bytes_cloud/core/manager/UserManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/entity/ShareEntity.dart';
import 'package:bytes_cloud/entity/TranslateTask.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:flutter/material.dart';

class DownloadTask extends TranslateTask {
  static String get tableName => 'DownloadTask' + UserManager.instance().userName;
  static getSQL() => '''
            CREATE TABLE $tableName(
            uuid INTEGER PRIMARY KEY,
            id TEXT, 
            filename TEXT, 
            path TEXT,
            token TEXT,
            time INTEGER, 
            sent INTEGER,
            total INTEGER)
  ''';
  String id; /// 云盘文件ID是[CloudFileEntity]的ID，分享的文件是 [ShareEntity] share_url
  String filename; // 文件存储的名字
  String path; // 文件存储的路径
  String token; // 分享文件下载时候需要token

  DownloadTask(
      {@required this.id, @required this.filename, @required this.path, this.token})
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
      'token' : token,
    });
    return result;
  }

  DownloadTask.formMap(Map map) : super.fromMap(map) {
    this.id = map[id];
    this.filename = map['filename'];
    this.path = map['path'];
    this.token = map['token'];
  }

  @override
  String get pathMsg => path.substring(0, path.length - filename.length);

  @override
  String get filePath => path;
}
