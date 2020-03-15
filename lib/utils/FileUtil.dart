import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileUtil {
  static String getFileName(String path) {
    String name = path.substring(path.lastIndexOf('/') + 1);
    if (name.contains('.')) {
      return name.substring(0, name.lastIndexOf('.'));
    }
    return name;
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

  static bool isImage(FileSystemEntity file) {
    String ext = p.extension(file.path);
    return ext == '.png' || ext == '.jpg';
  }

  static bool isPDF(FileSystemEntity file) {
    String ext = p.extension(file.path);
    return ext == '.pdf';
  }

  static bool isText(FileSystemEntity file) {
    String ext = p.extension(file.path);
    return ext == '.txt' || ext == '.xml' || ext == '.log';
  }

  static bool isMD(FileSystemEntity file) {
    String ext = p.extension(file.path);
    return ext == '.md';
  }

  // docx,doc,xlsx,xls,pptx,ppt,pdf,txt
  static bool isFileReaderSupport(FileSystemEntity file) {
    //return false;
    String ext = p.extension(file.path);
    return ext == '.docx' ||
        ext == '.doc' ||
        ext == '.xlsx' ||
        ext == '.xls' ||
        ext == '.pptx' ||
        ext == '.ppt' ||
        ext == '.txt' ||
        ext == '.pdf';
  }

  static bool isVideo(FileSystemEntity file) {
    String ext = p.extension(file.path);
    return ext == '.mp4' || ext == '.avi' || ext == '.3gp' || ext == '.flv';
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
}
