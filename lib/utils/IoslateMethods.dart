import 'dart:collection';
import 'dart:io';

// keys
List<FileSystemEntity> wapperGetAllFiles(Map args) {
  List<String> keys = args['keys'];
  List<String> paths = args['roots'];
  bool isExt = args['isExt'];
  isExt = isExt == null ? false : isExt;
  Set<FileSystemEntity> all = HashSet(
      equals: (e1, e2) => e1.path == e2.path, hashCode: (e) => e.path.hashCode);
  paths.forEach((f) {
    all.addAll(getAllFiles(keys, Directory(f), isExt));
  });
  return all.toList();
}

List<FileSystemEntity> getAllFiles(
    List<String> keys, Directory dir, bool isExt) {
  List<FileSystemEntity> list = [];
  List<FileSystemEntity> files = dir.listSync();
  files.forEach((f) {
    var type = f.statSync().type;
    if (type == FileSystemEntityType.directory && !f.path.contains('/.')) {
      list.addAll(getAllFiles(keys, f, isExt));
    } else if (type == FileSystemEntityType.file && !f.path.contains('/.')) {
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
  });
  return list;
}
