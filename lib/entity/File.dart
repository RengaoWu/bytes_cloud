import 'package:flutter/cupertino.dart';

abstract class Entity<T> {
  int id; //id号
  Map<String, dynamic> toMap();
  Entity.fromMap(Map<String, dynamic> map);
}

class FileEntity extends Entity<FileEntity> {
  static String TABLE_NAME = 'FileEntity';
  static List<String> FIELDS = [
    FIELD_ID,
    FIELD_NAME,
    FIELD_CREATE_TIME,
    FIELD_MODIFY_TIME,
    FIELD_PATH
  ];
  static String FIELD_ID = 'id';
  static String FIELD_NAME = 'name';
  static String FIELD_CREATE_TIME = 'createTime';
  static String FIELD_MODIFY_TIME = 'modifyTime';
  static String FIELD_PATH = 'path';

  static const String tableName = 'FileEntity';
  String name; //文件名
  String createTime;
  String modifyTime;
  String path; //路径

  static getSQL() => '''
                CREATE TABLE $tableName(
            $FIELD_ID INTEGER PRIMARY KEY, 
            $FIELD_NAME TEXT, 
            $FIELD_CREATE_TIME TEXT, 
            $FIELD_MODIFY_TIME TEXT, 
            $FIELD_PATH TEXT)
  ''';

  FileEntity(
      {@required id, this.name, this.createTime, this.modifyTime, this.path})
      : super.fromMap(null);

  @override
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      name: name,
      createTime: createTime,
      modifyTime: modifyTime,
      path: path
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  @override
  FileEntity.fromMap(Map<String, dynamic> map) : super.fromMap(null) {
    id = map[id];
    name = map[name];
    createTime = createTime;
    modifyTime = modifyTime;
    path = path;
  }
}
