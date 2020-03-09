import 'package:flutter/material.dart';
import 'Constants.dart';

class FileTypeUtils {
  static const String ARG_DOC = '文档';
  static const String ARG_ZIP = '压缩包';
  static const String ARG_MUSIC = '音乐';

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
    }
  }

  // 文档类型
  static Map<String, Widget> documentType2Icon = {
    Constants.TYPE_ALL: Text('A'),
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
    Constants.TYPE_ALL: Text('A'),
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
    Constants.TYPE_ALL: Text('A'),
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
}
