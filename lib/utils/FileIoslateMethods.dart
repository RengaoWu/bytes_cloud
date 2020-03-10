import 'dart:io';

List<FileSystemEntity> wapperGetAllFiles(Map args) {
  List<String> ext = args['ext'];
  String path = args['path'];
  return getAllFiles(ext, Directory(path));
}

List<FileSystemEntity> getAllFiles(List<String> ext, Directory dir) {
  List<FileSystemEntity> list = [];
  List<FileSystemEntity> files = dir.listSync();
  files.forEach((f) {
    var type = f.statSync().type;
    if (type == FileSystemEntityType.directory) {
      list.addAll(getAllFiles(ext, f));
    } else if (type == FileSystemEntityType.file) {
      int index = f.path.lastIndexOf('.');
      if (index > 1) {
        if (ext.contains(f.path.substring(index))) {
          list.add(f);
        }
      }
    }
  });
  return list;
}

List<FileSystemEntity> wapperGetFiles(Map<String, String> args) {
  List<FileSystemEntity> res = [];
  String key = args['key'];
  String root = args['root'];
  getFiles(key, Directory(root), res);
  return res;
}

getFiles(String key, Directory root, List<FileSystemEntity> res) {
  List<FileSystemEntity> files = root.listSync();
  files.forEach((f) {
    print(f.path);
    var type = f.statSync().type;
    if (type == FileSystemEntityType.directory) {
      getFiles(key, f, res);
    } else if (type == FileSystemEntityType.file) {
      if (f.path.contains(key)) {
        res.add(f);
      }
    }
  });
}
