import 'package:bytes_cloud/core/manager/TranslateManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/entity/DownloadTask.dart';
import 'package:bytes_cloud/entity/RecentFileEntity.dart';
import 'package:bytes_cloud/entity/ShareEntity.dart';
import 'package:bytes_cloud/entity/UploadTask.dart';
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

  Future init({bool force = false}) async {
    if (force) {
      if (_db != null) await _db.close();
      _db = await _open(await getDatabasesPath() + _dbName);
    }
    if (_db == null) {
      _db = await _open(await getDatabasesPath() + _dbName);
    }
  }

  Future<Database> _open(String path) async {
    return await openDatabase(path, version: 3,
        onCreate: (Database db, int version) async {
      print(RecentFileEntity.getSQL());
      await db.execute(RecentFileEntity.getSQL()); // 账号无关
    }, onOpen: (Database db) async {
      print(CloudFileEntity.getSQL());
      await createTable(db, CloudFileEntity.getSQL());

      print(DownloadTask.getSQL());
      await createTable(db, DownloadTask.getSQL());

      print(UploadTask.getSQL());
      await createTable(db, UploadTask.getSQL());

      print(ShareEntity.SQL_SHARE_CREATE);
      await createTable(db, ShareEntity.SQL_SHARE_CREATE);
    });
  }

  createTable(Database db, String sql) async {
    try {
      await db.execute(sql);
    } catch (e) {
      print(e);
    }
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
  Future<List<Map>> queryAll(String tableName, {String orderBy, String where, List<dynamic> args}) async {
    await init();
    List<Map> maps = await _db.query(tableName, orderBy: orderBy, where: where, whereArgs: args);
    if (maps == null) {
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
