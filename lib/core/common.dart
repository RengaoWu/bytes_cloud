import 'dart:io';

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
}
