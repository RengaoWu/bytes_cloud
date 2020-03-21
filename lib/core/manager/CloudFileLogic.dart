import 'dart:ffi';
import 'dart:io';

import 'package:bytes_cloud/core/common.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/entity/DBManager.dart';
import 'package:bytes_cloud/http/http.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

class CloudFileManager {
  List<CloudFileEntity> _entities = []; // 初始化
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
        e.uploadTime *= 1000; // 修正时间
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

  List<CloudFileEntity> listFiles(int pId, {justFolder = false}) {
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
    result.sort((a, b) {
      if (a.isFolder() && !b.isFolder())
        return -1;
      else if (!a.isFolder() && b.isFolder()) return 1;
      return a.uploadTime - b.uploadTime;
    });
    print('listFiles ${result.length}');
    return result;
  }

  int childrenCount(int pid, {justFolder = false}) {
    return listFiles(pid, justFolder: justFolder).length;
  }
}

class CloudFileHandle {
  // 获取所有的目录信息
  static Future reflashCloudFileList(
      {Function successCall, Function failedCall}) async {
    try {
      Map<String, dynamic> rsp =
          await httpGet(HTTP_GET_ALL_FILES, {'curUid': '0'});
      List maps = rsp['data'];
      List<CloudFileEntity> result = [];
      maps.forEach((json) {
        if (json['filename'] != null) {
          // 这里最好多检查一些字段
          result.add(CloudFileEntity.fromJson(json));
        }
      });
      print('getAllFile ${result.length}');
      await CloudFileManager.instance().saveAllCloudFiles(result); // 存DB
    } catch (e) {
      print('CloudFileHandle#getAllFile error! $e');
      if (failedCall != null) failedCall();
    }
    await CloudFileManager.instance().initDataFromDB(); // 更新内存数据
    if (successCall != null) successCall();
    return;
  }

  static Future newFolder(int curId, String folderName,
      {Function successCall, Function failedCall}) async {
    Map<String, dynamic> rsp;
    // 网络创建
    try {
      rsp = await httpPost(HTTP_POST_NEW_FOLDER,
          form: {'curId': curId, 'foldername': folderName});
    } catch (e) {
      failedCall({'code': -1, 'data': '', 'errMsg': '创建失败：网络错误'});
      return;
    }
    if (rsp['code'] != 0) {
      failedCall(rsp);
      return;
    }
    // 刷新DB
    try {
      await CloudFileManager.instance()
          .insertCloudFile(CloudFileEntity.fromJson(rsp['data']));
    } catch (e) {
      failedCall({'code': -1, 'data': '', 'errMsg': '插入数据库错误'});
      return;
    }
    successCall(rsp);
  }

  static Future uploadOneFile(int dirId, String path) async {
    String name = FileUtil.getFileNameWithExt(path);
    print('uploadOneFile ${path}');
    var resp = await httpPost(HTTP_POST_A_FILE, call: (sent, total) {
      print('$sent / $total');
    }, form: {
      'curId': 0,
      'file': await MultipartFile.fromFile(path, filename: name),
    });
    print(resp.toString());
  }

  static Future downloadOneFile(int id, String fileName) async {
    print('downloadOneFile ${id}');
    print(Common().appDownload);
    var resp = await httpDownload(HTTP_POST_DOWNLOAD_FILE, {'id': id},
        Common().appDownload + '/' + fileName);
  }
}
