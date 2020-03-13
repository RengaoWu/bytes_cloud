import 'package:flutter/services.dart';

class Constants {
  // Channel
  static const String COMMON_CHANNEL = 'common';
  static const String getThumbnails = 'getThumbnails';

  static const MethodChannel COMMON = MethodChannel(COMMON_CHANNEL);
  // File type
  static final String TYPE_ALL = '全部';
  static final String TYPE_DOC = 'DOC';
  static final String TYPE_XLS = 'XLS';
  static final String TYPE_PPT = 'PPT';
  static final String TYPE_TXT = 'TXT';
  static final String TYPE_PDF = 'PDF';
  static final String TYPE_ZIP = 'ZIP';
  static final String TYPE_RAR = 'RAR';
  static final String TYPE_7Z = '7Z';
  static final String TYPE_MP3 = 'MP3';
  static final String TYPE_WAV = 'WAV';
  static final String TYPE_FLAC = 'FLAC';
  static final String TYPE_AAC = 'AAC';

  static final String TYPE_MP4 = 'MP4';
  static final String TYPE_AVI = 'AVI';
  static final String TYPE_3GP = '3GP';
  static final String TYPE_FLV = 'FLV';

  /// {@link pubspec.yaml}
  static final String LOGO = 'images/logo.png';
  // static final String FOLDER = 'assets/images/folder.png';
  static final String IMAGE = 'assets/images/image.png';
  static final String PPT = 'assets/images/ppt.png';
  static final String WORD = 'assets/images/word.png';
  static final String EXCEL = 'assets/images/excel.png';
  static final String TXT = 'assets/images/txt.png';
  // static final String FILE = 'assets/images/file.png';
  static final String COMPRESSFILE = 'assets/images/compress_file.png';
  static final String MUSIC = 'assets/images/music.png';
  static final String VIDEO = 'assets/images/video.png';
  static final String PSD = 'assets/images/psd.png';
  static final String UNKNOW = 'assets/images/unknown.png';
  // file type - music
  static final String AAC = 'assets/images/aac.png';
  static final String MP3 = 'assets/images/mp3.png';
  static final String WAV = 'assets/images/wav.png';
  static final String FLAC = 'assets/images/flac.png';
  // file type - zip
  static final String ZIP = 'assets/images/zip.png';
  static final String RAR = 'assets/images/rar.png';
  static final String Z7 = 'assets/images/7z.png';
  // file type - video
  static final String GP3 = 'assets/images/3gp.png';
  static final String MP4 = 'assets/images/mp4.png';
  static final String AVI = 'assets/images/avi.png';
  static final String FLV = 'assets/images/flv.png';

  static final String PHOTO = 'assets/images/photo.png';
  static final String MCF = 'assets/images/audio.png';
  static final String AUDIO = 'assets/images/audio2.png';
  static final String SCAN = 'assets/images/scan.png';
  static final String FILE = 'assets/images/file.png';
  static final String FILE2 = 'assets/images/file2.png';
  static final String FOLDER = 'assets/images/folder2.png';
  static final String DOC = 'assets/images/doc.png';
  static final String NOTE = 'assets/images/note.png';
  static final String GROUP = 'assets/images/group.png';
  static final String MARK = 'assets/images/mark.png';
  static final String SETTING = 'assets/images/setting.png';
  static final String SHARE = 'assets/images/share.png';
  static final String TRASH = 'assets/images/trash.png';
  static final String FACEBACK = 'assets/images/faceback.png';
  static final String DOWNLOADED = 'assets/images/download.png';
  static final String CHANGE_USER = 'assets/images/change_user.png';
  static final String QQ = 'assets/images/QQ.png';
  static final String WECHAT = 'assets/images/wechat.png';
  static final String NULL = 'assets/images/null.png';
  static final String PHONE = 'assets/images/phone.png';
  static final String SCREAMSHOT = 'assets/images/screamshot.png';
  static final String CAMERA = 'assets/images/camera.png';

  static final int COLOR_DIVIDER = 0xffe5e5e5;
}
