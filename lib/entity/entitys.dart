import 'dart:io';

import 'package:bytes_cloud/core/common.dart';
import 'package:flutter/foundation.dart';

abstract class Entity {
  Map<String, dynamic> toMap();
  Entity.fromMap(Map<String, dynamic> map);
}

class RecentFileEntity extends Entity {
  static const String tableName = 'RecentFileEntity';

  String path; //路径
  int modifyTime;
  int createTime;
  String folder; //文件名
  int cloudTime;

  static getSQL() => '''
                CREATE TABLE RecentFileEntity(
            path TEXT PRIMARY KEY, 
            modifyTime INTEGER, 
            createTime INTEGER, 
            folder TEXT,
            cloudTime INTEGER)
  ''';
  RecentFileEntity(
      {@required this.path,
      this.createTime,
      this.modifyTime,
      this.folder,
      this.cloudTime})
      : super.fromMap(null);

  @override
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'path': path,
      'createTime': createTime,
      'modifyTime': modifyTime,
      'folder': folder,
      'cloudTime': cloudTime
    };
    return map;
  }

  @override
  RecentFileEntity.fromMap(Map<String, dynamic> map) : super.fromMap(null) {
    path = map['path'];
    createTime = map['createTime'];
    modifyTime = map['modifyTime'];
    folder = map['folder'];
    cloudTime = map['cloudTime'];
  }

  RecentFileEntity.forSystemFileEntity(FileSystemEntity entity)
      : super.fromMap(null) {
    path = entity.path;
    createTime = entity.statSync().changed.millisecondsSinceEpoch;
    modifyTime = entity.statSync().modified.millisecondsSinceEpoch;
    folder = fileFrom(entity.path);
    cloudTime = 0;
  }

  static fileFrom(String path) {
    if (path.startsWith(Common().WxRoot)) {
      return Common().WxRoot; // 先判断wx，再判断tencent(qq)
    } else if (path.startsWith(Common().TencentRoot)) {
      return Common().TencentRoot;
    } else if (path.startsWith(Common().DCIM)) {
      return Common().DCIM;
    } else if (path.startsWith(Common().screamShot)) {
      return Common().screamShot;
    } else {
      return '';
    }
  }
}
