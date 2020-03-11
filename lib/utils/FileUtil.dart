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
}
