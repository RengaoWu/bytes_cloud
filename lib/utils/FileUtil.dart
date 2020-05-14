import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bytes_cloud/core/Common.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/core/StaticConfig.dart';
import 'package:bytes_cloud/utils/SPUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

class FileUtil {
  static String getFileNameWithExt(String path) {
    return p.basename(path);
  }

  static String getFileName(String path) {
    return p.basenameWithoutExtension(path);
  }

  static String getFilePathWithoutName(String path) {
    return p.dirname(path);
  }

  static String ext(String path) {
    return p.extension(path);
  }

  static void writeToFile(
      {String path, String fileName, @required String content}) async {
    File file;
    if (path == null) {
      Directory dir = await getApplicationDocumentsDirectory();
      file = new File(dir.path + '/' + fileName);
    } else {
      file = new File(path);
    }
    if (!file.existsSync()) {
      file.createSync();
    }
    print(content);
    file.writeAsString(content);
  }

  static Future<String> readFromFile(String path) async {
    File file = new File(path);
    if (!file.existsSync()) {
      file.createSync();
    }
    return await file.readAsString();
  }

  static Future<List<FileSystemEntity>> listFiles(String path) async {
    Directory dir = await getApplicationDocumentsDirectory();
    Directory currentDir = new Directory(dir.path + '/' + path);
    if (!currentDir.existsSync()) {
      currentDir.createSync();
    }
    return currentDir.listSync();
  }

  static Future<FileSystemEntity> createFile(
      String path, String fileName, String ext) async {
    Directory dir = await getApplicationDocumentsDirectory();
    File file = new File(dir.path + '/' + path + '/' + fileName + ext);
    if (!file.existsSync()) {
      file.createSync();
      return file;
    }
    return null;
  }

  static void deleteFile(String path) {
    File file = File(path);
    if (file.existsSync()) file.deleteSync();
  }

  static bool isImage(String file) {
    return StaticConfig.imagesExt.contains(p.extension(file));
  }

  static bool isPDF(String file) {
    String ext = p.extension(file);
    return ext == '.pdf';
  }

  static bool isText(String file) {
    String ext = p.extension(file);
    return ext == '.txt' || ext == '.xml' || ext == '.log';
  }

  static bool isMD(String file) {
    String ext = p.extension(file);
    return ext == '.md';
  }

  // docx,doc,xlsx,xls,pptx,ppt,pdf,txt
  static bool isDoc(String file) {
    //return false;
    String ext = p.extension(file);
    return ext == '.docx' ||
        ext == '.doc' ||
        ext == '.xlsx' ||
        ext == '.xls' ||
        ext == '.pptx' ||
        ext == '.ppt' ||
        ext == '.txt' ||
        ext == '.pdf';
  }

  static bool isVideo(String file) {
    String ext = p.extension(file);
    return StaticConfig.videoExtension2Type.keys.contains(ext);
  }

  static String getFileSize(int fileSize) {
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

  static String getDownloadFilePath(CloudFileEntity entity) {
    return Common.instance.appDownload + entity.pathRoot + entity.fileName;
  }

  static String getShareDownloadFilePath(String filename){
    return Common.instance.appDownload + '/share_download/' + filename;
  }

  static Future<String> saveBytesAsFile(ByteData byteData) async {
    Uint8List png = byteData.buffer.asUint8List();
    String path = FileUtil.uri2Path(await ImageGallerySaver.saveImage(png));
    return path;
  }

  static bool haveDownloaded(CloudFileEntity entity) {
    return File(getDownloadFilePath(entity)).existsSync() &&
        SP.getBool(SP.downloadedKey(entity.id.toString()), false);
  }

  static bool isFile(String path) {
    if (path == null || path.trim() == '') {
      return false;
    }
    if (!File(path).existsSync()) {
      return false;
    }
    return true;
  }

  static String uri2Path(String url) {
    return url.substring(8); //  'file:///'
  }

  static Future<String> saveUI2Image(GlobalKey key) async {
    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    var image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List png = byteData.buffer.asUint8List();
    String path = FileUtil.uri2Path(await ImageGallerySaver.saveImage(png));
    Fluttertoast.showToast(msg: '保存到 ${path}');
    return path;
  }
}
