import 'dart:io';

import 'package:bytes_cloud/utils/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String sDCardDir;
  String get sDownloadDir =>
      sDCardDir + '/Download'; // android 'Download', ios null
  String get sWxDir => sDCardDir + '/Tencent/MicroMsg/Download';

  String get sQQDir => sDCardDir + '/Tencent';
  String get sQQFileRecDir => sQQDir + '/QQfile_recv'; // 文件
  String get sQQFileImageRecDir => sQQDir + '/QQfile_images'; // 聊天图片
  String get sQQFileCollRecDir => sQQDir + '/QQfile_colleaction'; //收藏
  String get sQQFavDir => sQQDir + '/QQ_Favorite'; //表情

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

  String selectIcon(String ext) {
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
        iconImg = Constants.IMAGE;
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
    return iconImg;
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
