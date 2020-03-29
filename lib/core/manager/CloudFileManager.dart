import 'package:bytes_cloud/core/handler/CloudFileHandler.dart';
import 'package:bytes_cloud/core/manager/TranslateManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/model/ListModel.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'DBManager.dart';

class CloudFileManager {
  ListModel<CloudFileEntity> _cloudFileModel = ListModel([]);
  ListModel<CloudFileEntity> get model => _cloudFileModel;

  CloudFileEntity _root = CloudFileEntity(-1, fileName: '云盘');
  CloudFileEntity get root => _root;
  static CloudFileManager _instance;

  static CloudFileManager instance() {
    if (_instance == null) {
      _instance = CloudFileManager._init();
    }
    return _instance;
  }

  CloudFileManager._init();

  // 查询所有
  Future initDataFromDB() async {
    List<Map> es =
        await DBManager.instance.queryAll(CloudFileEntity.tableName, null);
    if (es == null) return;
    _cloudFileModel.list = es.map((f) => CloudFileEntity.fromMap(f)).toList();
  }

  List<CloudFileEntity> get photos {
    List<CloudFileEntity> _photos = [];
    model.list.forEach((f) {
      if (f.type == 'png' || f.type == 'jpg' || f.type == 'jpeg') {
        _photos.add(f);
      }
    });
    print(_photos.length);
    return _photos;
  }

  CloudFileEntity getEntityById(int id) {
    try {
      return model.list.firstWhere((e) => e.id == id);
    } catch (e) {
      print('getEntityById ${e}');
      return null;
    }
  }

  List<CloudFileEntity> listRootFiles(
      {bool justFolder = false, bool r = false}) {
    return listFiles(_root.id, justFolder: justFolder, r: false);
  }

  List<CloudFileEntity> listFiles(int pId,
      {justFolder = false,
      Function sortFunc = CloudFileEntity.sortByTime,
      bool r = false}) {
    List<CloudFileEntity> result = [];
    model.list.forEach((f) {
      if (f.parentId == pId) {
        if (!justFolder) {
          result.add(f);
        } else if (justFolder && f.isFolder()) {
          if (r) {
            result.addAll(listFiles(f.id,
                justFolder: justFolder, sortFunc: sortFunc, r: r));
          } else {
            result.add(f);
          }
        }
      }
    });
    result.sort(sortFunc);
    return result;
  }

  int childrenCount(int pid, {justFolder = false, bool r = false}) {
    return listFiles(pid, justFolder: justFolder, r: r).length;
  }

  Future<bool> refreshCloudFileList() async {
    List<CloudFileEntity> es = await CloudFileHandle.refreshCloudFileList();
    print('refreshCloudFileList es.length = ${es?.length}');
    if (es == null) return false;
    //es.forEach(print);
    await CloudFileManager.instance().saveAllCloudFiles(es); // 存DB
    await CloudFileManager.instance().initDataFromDB(); // 更新内存数据
    return true;
  }

  // 增加
  Future<CloudFileEntity> insertCloudFile(CloudFileEntity entity) async {
    CloudFileEntity result = entity;
    _cloudFileModel.add(result); // 更新缓存
    return await DBManager.instance
        .insert(CloudFileEntity.tableName, entity); // 更新DB
  }

  // 全量写
  Future saveAllCloudFiles(List<CloudFileEntity> entities) async {
    await (await DBManager.instance.db).transaction((txn) async {
      Batch batch = txn.batch();
      batch.delete(CloudFileEntity.tableName); // 先 clear 本地数据库
      entities.forEach(
          (e) => batch.insert(CloudFileEntity.tableName, e.toMap()) // 再批量插入
          );
      await batch.commit(noResult: true);
    });
  }

  // 重命名
  Future<bool> renameFile(int id, String newName) async {
    CloudFileEntity entity = getEntityById(id);
    if (entity == null) return false;

    bool success = await CloudFileHandle.renameFile(id, newName);
    if (!success) return false;
    // 文件重命名，只需要更新名字
    if (!entity.isFolder()) {
      entity.fileName =
          newName + FileUtil.ext(entity.fileName); // update memory
      _cloudFileModel.update(entity, (e) => e.id == entity.id);
      await DBManager.instance.update(
          CloudFileEntity.tableName, entity, MapEntry('id', id)); // update db
    } else {
      // 文件夹重命名，更新名字，还要更新路径，太麻烦了，直接全量刷新
      await refreshCloudFileList();
    }
    return success;
  }

  deleteFile(int id) async {
    CloudFileEntity entity = getEntityById(id);
    if (entity == null) {
      print('deleteFile entity is null');
      return;
    }
    bool success = await CloudFileHandle.deleteFile(entity.id);
    print('deleteFile $success');
    if (!success) return false;
    // 文件删除，只需要删除一个文件
    if (!entity.isFolder()) {
      _cloudFileModel.remove((e) => e.id == entity.id); // 删除缓存
      await DBManager.instance.delete(
          CloudFileEntity.tableName, {'id': entity.id.toString()}); // 删除DB
    } else {
      await refreshCloudFileList();
    }
    return success;
  }

  Future newFolder(int pid, String name) async {
    CloudFileEntity entity = await CloudFileHandle.newFolder(pid, name);
    print('newFolder ${entity.toMap()}');
    bool success = entity != null;
    if (success) {
      _cloudFileModel.add(entity);
      DBManager.instance.insert(CloudFileEntity.tableName, entity);
    }
    return success;
  }

  Future<bool> downloadFile(List<CloudFileEntity> es) async {
    for (int i = 0; i < es.length; i++) {
      CloudFileEntity e = es[i];
      DownloadTask task = DownloadTask(
        id: e.id,
        filename: e.fileName,
        path: FileUtil.getDownloadFilePath(e),
      );
      TranslateManager.instant().downloadTask.add(task);
      await CloudFileHandle.downloadOneFile(task);
    }
    return true;
  }

  Future<bool> uploadFile(int pid, List<String> paths) async {
    for (int i = 0; i < paths.length; i++) {
      String f = paths[i];
      UploadTask task = UploadTask(path: f, pid: pid);
      TranslateManager.instant().uploadTask.add(task);
      CloudFileEntity entity = await CloudFileHandle.uploadOneFile(task);
      if (entity != null) {
        model.add(entity);
        await DBManager.instance.insert(CloudFileEntity.tableName, entity);
      }
    }
    return true;
  }
}
