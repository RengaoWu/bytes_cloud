import 'dart:collection';
import 'dart:io';

// keys
// 已经按照时间的新到旧排序
List<FileSystemEntity> wapperGetAllFiles(Map args) {
  List<String> keys = args['keys'];
  List<String> paths = args['roots'];
  bool isExt = args['isExt'];
  int fromTime = args['fromTime'];

  isExt = isExt == null ? false : isExt;
  fromTime = fromTime == null ? 0 : fromTime;
  Set<FileSystemEntity> all = HashSet(
      equals: (e1, e2) => e1.path == e2.path, hashCode: (e) => e.path.hashCode);
  paths.forEach((f) {
    all.addAll(_getAllFiles(keys, Directory(f), isExt, fromTime));
  });
  List<FileSystemEntity> result = all.toList();
  result.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
  return result;
}

List<FileSystemEntity> _getAllFiles(
    List<String> keys, Directory dir, bool isExt, int fromTime) {
  List<FileSystemEntity> list = [];
  List<FileSystemEntity> files = dir.listSync();

  files.forEach((f) {
    FileStat stat = f.statSync();
    // check update time
    if (stat.modified.millisecondsSinceEpoch > fromTime) {
      // while dir
      if (stat.type == FileSystemEntityType.directory &&
          !f.path.contains('/.')) {
        list.addAll(_getAllFiles(keys, f, isExt, fromTime));
        // while file
      } else if (stat.type == FileSystemEntityType.file &&
          !f.path.contains('/.')) {
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
  });
  return list;
}
