import 'package:bytes_cloud/core/Common.dart';
import 'package:bytes_cloud/core/Constants.dart';
import 'package:flutter/material.dart';

/// 静态配置文件
class StaticConfig {
  static const String ARG_DOC = '文档';
  static const String ARG_ZIP = '压缩包';
  static const String ARG_MUSIC = '音乐';
  static const String ARG_VIDEO = '视频';

  static const String FOLDER_AUTO_SYNC_WX = '微信文件同步文件夹';
  static const String FOLDER_AUTO_SYNC_QQ = 'QQ文件同步文件夹';
  static const String FOLDER_AUTO_SYNC_IMAGE = '相册文件同步文件夹';
  static const String FOLDER_AUTO_SYNC_MD = '笔记同步文件夹';

  static const _A = Text(
    'A',
    style: TextStyle(fontSize: 14),
  );

  static Set<String> imagesExt = {'.png', '.jpeg', '.gif', '.jpg'};

  static void convert(String type, Map<String, Widget> type2Icon,
      Map<String, String> ext2Type) {
    switch (type) {
      case ARG_DOC:
        type2Icon.addAll(documentType2Icon);
        ext2Type.addAll(documentExtension2Type);
        break;
      case ARG_ZIP:
        type2Icon.addAll(zipType2Icon);
        ext2Type.addAll(zipExtension2Type);
        break;
      case ARG_MUSIC:
        type2Icon.addAll(musicType2Icon);
        ext2Type.addAll(musicExtension2Type);
        break;
      case ARG_VIDEO:
        type2Icon.addAll(videoType2Icon);
        ext2Type.addAll(videoExtension2Type);
        break;
    }
  }

  // 文档类型
  static Map<String, Widget> documentType2Icon = {
    Constants.TYPE_ALL: _A,
    Constants.TYPE_DOC: Image.asset(Constants.DOC),
    Constants.TYPE_XLS: Image.asset(Constants.EXCEL),
    Constants.TYPE_PPT: Image.asset(Constants.PPT),
    Constants.TYPE_PDF: Image.asset(Constants.PSD),
    Constants.TYPE_TXT: Image.asset(Constants.TXT)
  };
  static Map<String, String> documentExtension2Type = {
    '.doc': Constants.TYPE_DOC,
    '.docx': Constants.TYPE_DOC,
    '.xls': Constants.TYPE_XLS,
    '.xlsx': Constants.TYPE_XLS,
    '.ppt': Constants.TYPE_PPT,
    '.pptx': Constants.TYPE_PPT,
    '.pdf': Constants.TYPE_PDF,
    '.txt': Constants.TYPE_TXT,
  };

  // 压缩文件
  static Map<String, Widget> zipType2Icon = {
    Constants.TYPE_ALL: _A,
    Constants.TYPE_ZIP: Image.asset(Constants.ZIP),
    Constants.TYPE_RAR: Image.asset(Constants.RAR),
    Constants.TYPE_7Z: Image.asset(Constants.Z7),
  };

  static Map<String, String> zipExtension2Type = {
    '.zip': Constants.TYPE_ZIP,
    '.rar': Constants.TYPE_RAR,
    '.7z': Constants.TYPE_7Z,
  };

  // 音频
  static Map<String, Widget> musicType2Icon = {
    Constants.TYPE_ALL: _A,
    Constants.TYPE_MP3: Image.asset(Constants.MP3),
    Constants.TYPE_WAV: Image.asset(Constants.WAV),
    Constants.TYPE_FLAC: Image.asset(Constants.FLAC),
    Constants.TYPE_AAC: Image.asset(Constants.AAC),
  };
  static Map<String, String> musicExtension2Type = {
    '.mp3': Constants.TYPE_MP3,
    '.wav': Constants.TYPE_WAV,
    '.flac': Constants.TYPE_FLAC,
    '.aac': Constants.TYPE_AAC,
  };

  // 视频
  static Map<String, Widget> videoType2Icon = {
    Constants.TYPE_ALL: _A,
    Constants.TYPE_MP4: Image.asset(Constants.MP4),
    Constants.TYPE_AVI: Image.asset(Constants.AVI),
    Constants.TYPE_FLV: Image.asset(Constants.FLV),
  };
  static Map<String, String> videoExtension2Type = {
    '.mp4': Constants.TYPE_MP4,
    '.flv': Constants.TYPE_FLAC,
    '.avi': Constants.TYPE_AVI,
  };

  // 是否按照文件类型展示
  static bool showType(String arg) {
    if (arg == ARG_VIDEO || arg == ARG_MUSIC)
      return false;
    else
      return true;
  }

  static List<String> getPaths(String arg) {
    return Common.instance.recentDir;
//    if (arg == ARG_VIDEO) {
//      return [
//        Common.instance.DCIM,
//        Common.instance.WxRoot,
//        Common.instance.TencentRoot
//      ]; // or so
//    }
//    return [Common.sd];
  }

  // 最近文件列表筛选的文件类型
  static List<String> recentFileExt() {
    List<String> list = [];
    list.addAll(StaticConfig.documentExtension2Type.keys);
    list.addAll(StaticConfig.videoExtension2Type.keys);
    list.addAll(StaticConfig.musicExtension2Type.keys);
    list.addAll(['.png', '.jpg']);
    list.remove('.txt');
    return list;
  }
}
