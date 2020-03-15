import 'package:bytes_cloud/entity/File.dart';
import 'package:sqflite/sqflite.dart';

class FileDB {
  String _CREATE_FILE_ENTITY_TABLE = FileEntity.getSQL();
  String dbName = 'local.db';
  Database _db;
  // 工厂模式
  factory FileDB() => _getInstance();
  static FileDB get instance => _getInstance();
  static FileDB _instance;

  static FileDB _getInstance() {
    if (_instance == null) {
      _instance = new FileDB._internal();
    }
    return _instance;
  }

  FileDB._internal() {
    // 初始化
    Future.wait([getDatabasesPath()]).then((onValue) {
      _db = _open(onValue[0] + dbName);
    });
  }

  _open(String path) async {
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(_CREATE_FILE_ENTITY_TABLE);
    });
  }

  // 插入一条书籍数据
  Future<FileEntity> insert(FileEntity entity) async {
    entity.id = await _db.insert(FileEntity.TABLE_NAME, entity.toMap());
    return entity;
  }

  // 查找所有书籍信息
  Future<List<Entity>> queryAll() async {
    List<Map> maps =
        await _db.query(FileEntity.TABLE_NAME, columns: FileEntity.FIELDS);
    if (maps == null || maps.length == 0) {
      return null;
    }
    return maps.map((map) => FileEntity.fromMap(map)).toList();
  }

  // 根据ID查找书籍信息
  Future<FileEntity> getFile(int id) async {
    List<Map> maps = await _db.query(FileEntity.TABLE_NAME,
        columns: FileEntity.FIELDS,
        where: '${FileEntity.FIELD_ID} = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return FileEntity.fromMap(maps.first);
    }
    return null;
  }

  // 根据ID删除书籍信息
  Future<int> delete(int id) async {
    return await _db.delete(FileEntity.TABLE_NAME,
        where: '${FileEntity.FIELD_ID} = ?', whereArgs: [id]);
  }

  // 更新书籍信息
  Future<int> update(FileEntity entity) async {
    return await _db.update(FileEntity.TABLE_NAME, entity.toMap(),
        where: '${FileEntity.FIELD_ID} = ?', whereArgs: [entity.id]);
  }

  // 记得及时关闭数据库，防止内存泄漏
  close() async {
    await _db.close();
  }
}
