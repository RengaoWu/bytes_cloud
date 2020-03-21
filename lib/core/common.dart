import 'dart:core';
import 'dart:io';

import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileTypeConfig.dart';

class Common {
  factory Common() => _getInstance();

  static Common get instance => _getInstance();
  static Common _instance; // 单例对象

  static Common _getInstance() {
    if (_instance == null) {
      _instance = Common._internal();
    }
    return _instance;
  }

  Common._internal();

  static String sd;
  static String appRoot;
  String get downloadDir => sd + '/Download'; // android 'Download', ios null
  String get appCache => appRoot + '/cache';
  String get appDownload => sd + '/字节云保存的文件';

  // wx
  String get WxRoot => sd + '/Tencent/MicroMsg';
  String get sWxDirDownload => WxRoot + '/Download';
  String get sWxMsg => WxRoot + '/WeiXin';

  // qq
  String get TencentRoot => sd + '/Tencent';
  String get sQQFileRecDir => TencentRoot + '/QQfile_recv'; // 文件
  String get sQQFileImageRecDir => TencentRoot + '/QQfile_images'; // 聊天图片
  String get sQQFileCollRecDir => TencentRoot + '/QQfile_colleaction'; //收藏
  String get sQQFavDir => TencentRoot + '/QQ_Favorite'; //表情

  String get DCIM => sd + '/DCIM';
  String get screamShot =>
      sd + '/Pictures/Screenshots'; // 华为手机[截图] /DCIM/Screenshots
  String get camera => sd + '/DCIM/Camera'; // 相机

  // 最近的文件：来源：微信、QQ、下载管理器、相机、QQ邮箱、浏览器、百度网盘、音乐、
  //
  List<String> get recentDir => <String>[
        sQQFileRecDir,
        sWxDirDownload,
        sWxMsg,
        DCIM,
        screamShot
      ]; // wx 和 qq的文件有重合，先判断是否是wx
  List<String> recentFileExt() {
    List<String> list = [];
    list.addAll(FileTypeConfig.documentExtension2Type.keys);
    list.addAll(FileTypeConfig.videoExtension2Type.keys);
    list.addAll(FileTypeConfig.musicExtension2Type.keys);
    list.addAll(['.png', '.jpg']);
    list.remove('.txt');
    return list;
  }

  List<FileSystemEntity> get qqFiles => [
        Directory(sQQFileRecDir),
        Directory(sQQFileImageRecDir),
        Directory(sQQFileCollRecDir),
        Directory(sQQFavDir),
      ];
}
