import 'dart:core';
import 'dart:io';

import 'package:bytes_cloud/utils/SPUtil.dart';

/// 动态配置文件
/// 打开APP的时候需要初始化
class Common {
  static Common get instance => _getInstance();
  static Common _instance; // 单例对象

  static Common _getInstance() {
    if (_instance == null) {
      _instance = Common._internal();
    }
    return _instance;
  }

  Common._internal() {
    wxAutoSync = SP.getBool(SP.KEY_SYNC_WX, false);
    qqAutoSync = SP.getBool(SP.KEY_SYNC_QQ, false);
    imageAutoSync = SP.getBool(SP.KEY_SYNC_IMAGE, false);
    translateInGPRS = SP.getBool(SP.KEY_TRANSLATE_ONLY_IN_GPRS, true);
    showHiddenFile = SP.getBool(SP.KEY_SHOW_HIDDEN_FILE, false);
  }

  static int availableSize;
  static int allSize;
  static int get used => allSize - availableSize;
  static String sd;
  static String appRoot;
  String get downloadDir => sd + '/Download'; // android 'Download', ios null
  String get appCache => appRoot + '/cache';
  String get appDownload => sd + '字节云保存的文件';

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
  String get screamShot {
    if(File(sd + '/Pictures/Screenshots').existsSync()) {
      return sd + '/Pictures/Screenshots';
    } else {
      return sd + '/DCIM/Screenshots';
    }
  } // 华为手机[截图] /DCIM/Screenshots
  String get camera => sd + '/DCIM/Camera'; // 相机

  // 最近的文件：来源：微信、QQ、下载管理器、相机、QQ邮箱、浏览器、百度网盘、音乐、
  List<String> get recentDir {
    List<String> result = [];
    if(File(sQQFileRecDir).existsSync()) result.add(sQQFileRecDir);
    if(File(sWxDirDownload).existsSync()) result.add(sWxDirDownload);
    if(File(sWxMsg).existsSync()) result.add(sWxMsg);
    if(File(DCIM).existsSync()) result.add(DCIM);
    if(File(screamShot).existsSync()) result.add(screamShot);
    return result;
  } // wx 和 qq的文件有重合，先判断是否是wx

  List<FileSystemEntity> get qqFiles => [
        Directory(sQQFileRecDir),
        Directory(sQQFileImageRecDir),
        Directory(sQQFileCollRecDir),
        Directory(sQQFavDir),
      ];

  // 自动上传开关
  bool qqAutoSync = false;
  bool wxAutoSync = false;
  bool imageAutoSync = false;
  List<String> get autoSyncDirs {
    if (wxAutoSync) {
      autoSyncDirs.add(sWxDirDownload);
      autoSyncDirs.add(sWxMsg);
    }
    if (qqAutoSync) {
      autoSyncDirs.add(sQQFileRecDir);
    }
    if (imageAutoSync) {
      autoSyncDirs.add(DCIM);
    }
  }

  // 流量下是否上传下载
  bool translateInGPRS = false;

  // 是否显示隐藏文件夹
  bool showHiddenFile = false;
}
