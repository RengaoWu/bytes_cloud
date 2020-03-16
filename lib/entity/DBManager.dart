import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'entitys.dart';

class DBManager {
  static const String _dbName = 'local.db';
  static DBManager get instance => _getInstance();
  static DBManager _instance;
  Database _db;

  static DBManager _getInstance() {
    if (_instance == null) {
      _instance = DBManager._internal();
    }
    return _instance;
  }

  DBManager._internal() {
//    Future.wait([getDatabasesPath()]).then((onValue) {
//      Future.wait([_open(onValue[0] + _dbName)]).then((value) {
//        _db = value[0];
//      });
//    });
  }

  init() async {
    if (_db == null) {
      _db = await _open(await getDatabasesPath() + _dbName);
    }
  }

  Future<Database> _open(String path) async {
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(RecentFileEntity.getSQL());
    });
  }

  // 增
  Future<Entity> insert(String tableName, Entity entity) async {
    await init();
    await _db.insert(tableName, entity.toMap());
    return entity;
  }

  // 删
  static String pattern = '= ? and';
  Future<int> delete(String tableName, Map<String, String> whereArg) async {
    await init();
    String where = '';
    List<String> arg = [];
    whereArg.forEach((k, v) {
      where += k + pattern;
      arg.add(v);
    });
    where = where.substring(0, where.length - pattern.length);
    return await _db.delete(tableName, where: where, whereArgs: arg);
  }

  //  改
  Future<int> update(String tableName, Entity entity, MapEntry whereArg) async {
    await init();
    return await _db.update(tableName, entity.toMap(),
        where: '${whereArg.key} = ?', whereArgs: [whereArg.value]);
  }

  // 查
  Future<List<Map>> queryAll(String tableName, String orderBy) async {
    await init();
    List<Map> maps = await _db.query(tableName, orderBy: orderBy);
    if (maps == null || maps.length == 0) {
      return null;
    }
    print('queryAll ${maps.length}');
    return maps;
  }

  // 条件查
  Future<List<Map>> getFile(
      String tableName, Map<String, String> whereArg) async {
    await init();
    String where = '';
    List<String> arg = [];
    whereArg.forEach((k, v) {
      where += k + pattern;
      arg.add(v);
    });
    where = where.substring(0, where.length - pattern.length);

    return await _db.query(tableName, where: where, whereArgs: arg);
  }

  // 记得及时关闭数据库，防止内存泄漏
  close() async {
    await _db.close();
  }
}
