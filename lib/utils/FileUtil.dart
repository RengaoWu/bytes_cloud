import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class FileUtil {
  static String getFileName(String path) =>
      path.substring(path.lastIndexOf('/') + 1);

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

  static void createFile(String path, String fileName) async {
    Directory dir = await getApplicationDocumentsDirectory();
    File file = new File(dir.path + '/' + path + '/' + fileName);
    if (!file.existsSync()) {
      file.createSync();
    }
  }

  static void deleteFile(String path) {
    File file = File(path);
    if (file.existsSync()) file.deleteSync();
  }
}
