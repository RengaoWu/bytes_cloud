import 'dart:collection';
import 'dart:io';

import 'package:bytes_cloud/core/Common.dart';
import 'package:flutter/foundation.dart';

// keys
// 已经按照时间的新到旧排序
Future<List<FileSystemEntity>> computeGetAllFiles(
    {@required List<String> roots,
    @required List<String> keys,
    bool isExt = false,
    int fromTime = 0}) async {
  bool skipHidden = !Common.instance.showHiddenFile;
  return await compute(_wrapperGetAllFiles, {
    'keys': keys,
    'roots': roots,
    'isExt': isExt,
    'fromTime': fromTime,
    'skipHidden': skipHidden,
  });
}

List<FileSystemEntity> _wrapperGetAllFiles(Map args) {
  List<String> keys = args['keys'];
  List<String> paths = args['roots'];
  bool isExt = args['isExt'];
  int fromTime = args['fromTime'];
  bool skipHidden = args['skipHidden'];

  Set<FileSystemEntity> all = HashSet(
      equals: (e1, e2) => e1.path == e2.path, hashCode: (e) => e.path.hashCode);
  paths.forEach((f) {
    all.addAll(_getAllFiles(keys, Directory(f), isExt, fromTime, skipHidden));
  });
  List<FileSystemEntity> result = all.toList();
  result.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
  return result;
}

List<FileSystemEntity> _getAllFiles(List<String> keys, Directory dir,
    bool isExt, int fromTime, bool skipHidden) {
  List<FileSystemEntity> list = [];
  List<FileSystemEntity> files = dir.listSync();

  files.forEach((f) {
    FileStat stat = f.statSync();
    // check update time
    if (stat.modified.millisecondsSinceEpoch > fromTime) {
      // while dir
      if (stat.type == FileSystemEntityType.directory) {
        if (!skipHidden || !f.path.contains('/.')) {
          list.addAll(_getAllFiles(keys, f, isExt, fromTime, skipHidden));
        }
        // while file
      } else if (stat.type == FileSystemEntityType.file) {
        if (!skipHidden || !f.path.contains('/.')) {
          for (int i = 0; i < keys.length; i++) {
            if (f.path.contains(keys[i])) {
              if (isExt) {
                if (f.path.endsWith(keys[i])) {
                  list.add(f);
                  break;
                }
              } else {
                list.add(f);
                break;
              }
            }
          }
        }
      }
    }
  });
  return list;
}
