import 'dart:io';

import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:thumbnails/thumbnails.dart';

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

  // wx
  String get WxRoot => sd + '/Tencent/MicroMsg';
  String get sWxDirDownload => WxRoot + '/Download';

  // qq
  String get QQRoot => sd + '/Tencent';
  String get sQQFileRecDir => QQRoot + '/QQfile_recv'; // 文件
  String get sQQFileImageRecDir => QQRoot + '/QQfile_images'; // 聊天图片
  String get sQQFileCollRecDir => QQRoot + '/QQfile_colleaction'; //收藏
  String get sQQFavDir => QQRoot + '/QQ_Favorite'; //表情

  String get DCIM => sd + '/DCIM';
  String get screamShot =>
      sd + '/Pictures/Screenshots'; // 华为手机[截图] /DCIM/Screenshots
  String get camera => sd + '/DCIM/Camera'; // 相机

  List<FileSystemEntity> get qqFiles => [
        Directory(sQQFileRecDir),
        Directory(sQQFileImageRecDir),
        Directory(sQQFileCollRecDir),
        Directory(sQQFavDir),
      ];

  String getFileSize(int fileSize) {
    String str = '';

    if (fileSize < 1024) {
      str = '${fileSize.toStringAsFixed(2)}B';
    } else if (1024 <= fileSize && fileSize < 1048576) {
      str = '${(fileSize / 1024).toStringAsFixed(2)}KB';
    } else if (1048576 <= fileSize && fileSize < 1073741824) {
      str = '${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB';
    }

    return str;
  }

  Widget selectIcon(String path, bool preview) {
    int resFlag = 0; // 图片 1, 视频 2
    String ext = p.extension(path);
    String iconImg = Constants.UNKNOW;

    switch (ext) {
      case '.ppt':
      case '.pptx':
        iconImg = Constants.PPT;
        break;
      case '.doc':
      case '.docx':
        iconImg = Constants.DOC;
        break;
      case '.xls':
      case '.xlsx':
        iconImg = Constants.EXCEL;
        break;
      case '.jpg':
      case '.jpeg':
      case '.png':
        iconImg = preview ? path : Constants.IMAGE;
        resFlag = preview ? 1 : resFlag;
        break;
      case '.txt':
        iconImg = Constants.TXT;
        break;
      case '.mp3':
        iconImg = Constants.MP3;
        break;
      case '.wav':
        iconImg = Constants.WAV;
        break;
      case '.flac':
        iconImg = Constants.FLAC;
        break;
      case '.aac':
        iconImg = Constants.AAC;
        break;
      case '.mp4':
        iconImg = Constants.MP4;
        break;
      case '.avi':
        iconImg = Constants.AVI;
        break;
      case '.flv':
        iconImg = Constants.FLV;
        break;
      case '3gp':
        iconImg = Constants.GP3;
        break;
      case '.rar':
        iconImg = Constants.RAR;
        break;
      case '.zip':
        iconImg = Constants.ZIP;
        break;
      case '.7z':
        iconImg = Constants.Z7;
        break;
      case '.psd':
      case '.pdf':
        iconImg = Constants.PSD;
        break;
      default:
        iconImg = Constants.FILE;
        break;
    }
    if (resFlag == 1) {
      return ClipRect(
        child: Image.file(
          File(path),
          width: 40,
          height: 40,
        ),
      );
    } else {
      return Image.asset(
        iconImg,
        width: 40,
        height: 40,
      );
    }
  }

  Future saveStr(String key, String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(key, value);
  }

  Future saveStrList(String key, List<String> values) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setStringList(key, values);
  }

  Future readStr(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String account = preferences.get(key);
  }

  Future removeStr(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(key);
  }
}
