import 'dart:io';

import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/entity/DBManager.dart';
import 'package:bytes_cloud/http/http.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

class CloudFileManager {
  List<CloudFileEntity> _entities = []; // 初始化
  CloudFileEntity _root;
  static CloudFileManager _instance;

  CloudFileManager._init() {
    //_initData();
  }

  int get rootId => _root.id;

  _initData() async {
    List es =
        await DBManager.instance.queryAll(CloudFileEntity.tableName, null);
    print(es.length);
    if (es == null) return;
    List<CloudFileEntity> temp = [];
    es.forEach((f) {
      CloudFileEntity entity = CloudFileEntity.fromJson(f);
      if (entity.id == 0) {
        _root = entity;
      } else {
        temp.add(entity);
      }
    });
    _entities = temp;
  }

  static CloudFileManager instance() {
    if (_instance == null) {
      _instance = CloudFileManager._init();
    }
    return _instance;
  }

  // 存DB
  saveAll(List<CloudFileEntity> entities) async {
    await DBManager.instance.db.transaction((txn) async {
      Batch batch = txn.batch();
      batch.delete(CloudFileEntity.tableName); // 先 clear 本地数据库
      entities.forEach((e) {
        batch.insert(CloudFileEntity.tableName, e.toMap()); // 再批量插入
      });
      await batch.commit(noResult: true);
    });
    await _initData();
  }

  listRootFiles() {
    return listFiles(_root.id);
  }

  listFiles(int pId) {
    List<CloudFileEntity> result = [];
    _entities.forEach((f) {
      if (f.parentId == pId) {
        result.add(f);
      }
    });
    print('listFiles ${result.length}');
    return result;
  }
}

class CloudFileHandle {
  // 获取所有的目录信息
  static Future<List<CloudFileEntity>> getAllFile() async {
    Map<String, dynamic> rsp =
        await httpGet(HTTP_GET_ALL_FILES, {'curUid': '0'});
    List maps = rsp['data'];
    print('getAllFile ${maps.length}');
    List<CloudFileEntity> result = [];
    maps.forEach((json) {
      if (json['filename'] != null) {
        // 这里最好多检查一些字段
        result.add(CloudFileEntity.fromJson(json));
      }
    });
    print('getAllFile ${result.length}');
    await CloudFileManager.instance().saveAll(result); // 存DB
    return result;
  }

  static Future uploadOneFile(int dirId, String path) async {
    //String name = FileUtil.getFileName(path);
    print('uploadOneFile ${path}');
    var resp = await httpPost(HTTP_POST_A_FILE, call: (sent, total) {
      print('$sent / $total');
    }, form: {
      'curId': 0,
      'file': await MultipartFile.fromFile(path, filename: 'name'),
    });
  }
}
