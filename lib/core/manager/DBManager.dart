import 'package:bytes_cloud/core/manager/TranslateManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/entity/RecentFileEntity.dart';
import 'package:bytes_cloud/entity/ShareEntity.dart';
import 'package:bytes_cloud/entity/User.dart';
import 'package:bytes_cloud/entity/entitys.dart';
import 'package:sqflite/sqflite.dart';

class DBManager {
  static const String _dbName = 'local.db';
  static DBManager get instance => _getInstance();
  static DBManager _instance;
  Database _db;
  Future<Database> get db async {
    await init();
    return _db;
  }

  static DBManager _getInstance() {
    if (_instance == null) {
      _instance = DBManager();
    }
    return _instance;
  }

  Future init() async {
    if (_db == null) {
      _db = await _open(await getDatabasesPath() + _dbName);
    }
  }

  Future<Database> _open(String path) async {
    return await openDatabase(path, version: 2,
        onCreate: (Database db, int version) async {
      await db.execute(RecentFileEntity.getSQL());
      await db.execute(CloudFileEntity.getSQL());
      await db.execute(DownloadTask.getSQL());
      await db.execute(UploadTask.getSQL());
      await db.execute(ShareEntity.SQL_SHARE_CREATE);
      print('DBManager _open finished');

//      await db.execute(UserEntity.getSQL());
    });
  }

  // 增
  Future<Entity> insert(String tableName, Entity entity) async {
    await init();
    await _db.insert(tableName, entity.toMap());
    return entity;
  }

  // 删
  static const String AND = ' and ';
  Future<int> delete(String tableName, Map<String, String> whereArg) async {
    await init();

    String where = '';
    List<String> arg = [];
    whereArg.forEach((k, v) {
      where += k + ' = ? ' + AND;
      arg.add(v);
    });
    where = where.substring(0, where.length - AND.length);
    print('DBManager delete where = ${where} , args = ${arg.toString()}');
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
      where += k + AND;
      arg.add(v);
    });
    where = where.substring(0, where.length - AND.length);

    return await _db.query(tableName, where: where, whereArgs: arg);
  }

  // 记得及时关闭数据库，防止内存泄漏
  close() async {
    await _db.close();
  }
}
