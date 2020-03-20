import 'dart:io';

import 'package:bytes_cloud/core/common.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:flutter/foundation.dart';

import 'entitys.dart';

class RecentFileEntity extends Entity {
  static const String tableName = 'RecentFileEntity';

  String path; //路径
  int modifyTime;
  int groupMd5; // hashCode(时间 + 文件夹 + 文件类型)
  int cloudTime;

  static getSQL() => '''
                CREATE TABLE RecentFileEntity(
            path TEXT PRIMARY KEY, 
            modifyTime INTEGER, 
            createTime INTEGER, 
            groupMd5 INTEGER,
            cloudTime INTEGER)
  ''';
  RecentFileEntity(
      {@required this.path, this.modifyTime, this.groupMd5, this.cloudTime})
      : super.fromMap(null);

  @override
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'path': path,
      'modifyTime': modifyTime,
      'groupMd5': groupMd5,
      'cloudTime': cloudTime
    };
    return map;
  }

  @override
  RecentFileEntity.fromMap(Map<String, dynamic> map) : super.fromMap(null) {
    path = map['path'];
    modifyTime = map['modifyTime'];
    groupMd5 = map['groupMd5'];
    cloudTime = map['cloudTime'];
  }

  RecentFileEntity.forSystemFileEntity(FileSystemEntity entity)
      : super.fromMap(null) {
    path = entity.path;
    DateTime time = entity.statSync().modified;
    modifyTime = time.millisecondsSinceEpoch;
    groupMd5 = (fileFrom(path) + FileUtil.ext(path)).hashCode +
        time.year +
        time.month +
        time.day;
    cloudTime = 0;
  }

  static fileFrom(String path) {
    if (path.startsWith(Common().WxRoot)) {
      return '微信'; // 先判断wx，再判断tencent(qq)
    } else if (path.startsWith(Common().TencentRoot)) {
      return 'QQ';
    } else if (path.startsWith(Common().DCIM)) {
      return '相册';
    } else if (path.startsWith(Common().screamShot)) {
      return '截图';
    } else {
      return '其他';
    }
  }

  static fileType(String path) {
    if (FileUtil.isImage(path)) {
      return '图片';
    } else if (FileUtil.isVideo(path)) {
      return '视频';
    } else if (FileUtil.isDoc(path)) {
      return '文档';
    }
  }

  static fileIcon(String source) {
    String sourceIcon;
    if (source == '微信') {
      sourceIcon = Constants.WECHAT;
    } else if (source == 'QQ') {
      sourceIcon = Constants.QQ;
    } else if (source == '文档') {
      sourceIcon = Constants.DOC;
    } else if (source == '截图') {
      sourceIcon = Constants.SCREAMSHOT;
    } else if (source == '相册') {
      sourceIcon = Constants.PHOTO;
    } else {
      sourceIcon = Constants.UNKNOW;
    }
    return sourceIcon;
  }
}
