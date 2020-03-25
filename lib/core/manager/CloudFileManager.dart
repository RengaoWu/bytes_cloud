import 'dart:io';

import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:sqflite/sqflite.dart';

import 'DBManager.dart';

class CloudFileManager {
  List<CloudFileEntity> _entities = []; // 初始化
  List<CloudFileEntity> get photos {
    List<CloudFileEntity> _photos = [];
    _entities.forEach((f) {
      if (f.type == 'png' || f.type == 'jpg' || f.type == 'jpeg') {
        _photos.add(f);
      }
    });
    return _photos;
  }

  CloudFileEntity _root;
  int get rootId => _root.id;
  static CloudFileManager _instance;
  static bool _isInit = false;

  static CloudFileManager instance() {
    if (_instance == null) {
      _instance = CloudFileManager._init();
    }
    return _instance;
  }

  CloudFileManager._init() {
    initDataFromDB().whenComplete(() {
      _isInit = true;
    });
  }

  // 读取数据库的数据
  Future initDataFromDB() async {
    List es =
        await DBManager.instance.queryAll(CloudFileEntity.tableName, null);
    if (es == null) return;
    List<CloudFileEntity> temp = [];
    es.forEach((f) {
      CloudFileEntity entity = CloudFileEntity.fromJson(f);
      if (entity.id == 0) {
        _root = entity;
        print('_root 初始化完成');
        print(_root.toMap());
      }
      temp.add(entity);
    });
    _entities = temp;
  }

  Future<CloudFileEntity> insertCloudFile(CloudFileEntity entity) async {
    CloudFileEntity result = entity;
    try {
      _entities.add(result); // 更新缓存
      result = await DBManager.instance
          .insert(CloudFileEntity.tableName, entity); // 更新DB
    } catch (e) {
      print("insertCloudFile error!");
      result = null;
    }
    return result;
  }

  // 存DB
  saveAllCloudFiles(List<CloudFileEntity> entities) async {
    await (await DBManager.instance.db).transaction((txn) async {
      Batch batch = txn.batch();
      batch.delete(CloudFileEntity.tableName); // 先 clear 本地数据库
      entities.forEach((e) {
        batch.insert(CloudFileEntity.tableName, e.toMap()); // 再批量插入
      });
      await batch.commit(noResult: true);
    });
  }

  CloudFileEntity getEntityById(int id) {
    try {
      return _entities.firstWhere((e) {
        print('${e.id} == $id');
        return e.id == id;
      });
    } catch (e) {
      print('getEntityById ' + e.toString());
    }
    print('getEntityById null');
    return null;
  }

  List<CloudFileEntity> listRootFiles({bool justFolder = false}) {
    return listFiles(_root.id, justFolder: justFolder);
  }

  // sort type
  // type = 0 time default
  // type = 1 A-z
  List<CloudFileEntity> listFiles(int pId, {justFolder = false, type = 0}) {
    List<CloudFileEntity> result = [];
    _entities.forEach((f) {
      if (f.parentId == pId) {
        if (!justFolder) {
          result.add(f);
        } else if (justFolder && f.isFolder()) {
          result.add(f);
          print(f.uploadTime);
        }
      }
    });
    // 排序，文件夹在前，文件在后，uploadTime 由远到近
    if (type == 0) {
      result.sort((a, b) {
        if (a.isFolder() && !b.isFolder())
          return -1;
        else if (!a.isFolder() && b.isFolder()) return 1;
        return a.uploadTime - b.uploadTime;
      });
    } else if (type == 1) {
      result.sort((a, b) {
        if (a.isFolder() && !b.isFolder())
          return -1;
        else if (!a.isFolder() && b.isFolder()) return 1;
        return a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase());
      });
    }
    return result;
  }

  int childrenCount(int pid, {justFolder = false}) {
    return listFiles(pid, justFolder: justFolder).length;
  }

  renameFile(int id, String newName) async {
    CloudFileEntity entity = getEntityById(id);
    if (entity == null) {
      return;
    }
    entity.fileName = newName; // update memory
    await DBManager.instance.update(
        CloudFileEntity.tableName, entity, MapEntry('id', id)); // update db
  }
}
