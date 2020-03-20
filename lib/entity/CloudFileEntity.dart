import 'package:bytes_cloud/entity/entitys.dart';

// ID = 0 表示根目录
class CloudFileEntity extends Entity {
  static const String tableName = 'CloudFileEntity';
  static getSQL() => '''
            CREATE TABLE $tableName(
            filename TEXT PRIMARY KEY, 
            id INTEGER, 
            parent_id INTEGER, 
            path_root TEXT,
            size INTEGER,
            type_of_node TEXT,
            uid INTEGER,
            upload_time INTEGER)
  ''';

  String fileName = '';
  int id;
  int parentId;
  String pathRoot;
  int size;
  String type; // dir or 具体的文件类型
  int uid; // 0 暂时没用
  int uploadTime; // 上传时间

  CloudFileEntity.fromJson(Map map) : super.fromMap(null) {
    fileName = map['filename'];
    id = map['id'];
    parentId = map['parent_id'];
    pathRoot = map['path_root'];
    size = map['size'];
    type = map['type_of_node'];
    uid = map['uid'];
    uploadTime = map['upload_time'];
  }

  @override
  Map<String, dynamic> toMap() {
    print({
      'filename': fileName,
      'id': id,
      'parent_id': parentId,
      'path_root': pathRoot,
      'size': size,
      'type_of_node': type,
      'uid': uid,
      'upload_time': uploadTime
    });
    return {
      'filename': fileName,
      'id': id,
      'parent_id': parentId,
      'path_root': pathRoot,
      'size': size,
      'type_of_node': type,
      'uid': uid,
      'upload_time': uploadTime
    };
  }

  isFolder() {
    return type == 'dir';
  }
}
