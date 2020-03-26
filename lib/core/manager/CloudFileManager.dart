import 'package:bytes_cloud/core/handler/CloudFileHandler.dart';
import 'package:bytes_cloud/core/manager/TranslateManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import 'DBManager.dart';

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

  List<CloudFileEntity> get photos {
    List<CloudFileEntity> _photos = [];
    _entities.forEach((f) {
      if (f.type == 'png' || f.type == 'jpg' || f.type == 'jpeg') {
        _photos.add(f);
      }
    });
    return _photos;
  }

  CloudFileEntity getEntityById(int id) =>
      _entities.firstWhere((e) => e.id == id);

  List<CloudFileEntity> listRootFiles(
      {bool justFolder = false, bool r = false}) {
    return listFiles(_root.id, justFolder: justFolder, r: false);
  }

  List<CloudFileEntity> listFiles(int pId,
      {justFolder = false,
      Function sortFunc = CloudFileEntity.sortByTime,
      bool r = false}) {
    List<CloudFileEntity> result = [];
    _entities.forEach((f) {
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

  Future<bool> reflashCloudFileList() async {
    List<CloudFileEntity> es = await CloudFileHandle.reflashCloudFileList();
    if (es == null) return false;
    await CloudFileManager.instance().initDataFromDB(); // 更新内存数据
    await CloudFileManager.instance().saveAllCloudFiles(es); // 存DB
    return true;
  }

  // 查询所有
  Future initDataFromDB() async {
    List<Map> es =
        await DBManager.instance.queryAll(CloudFileEntity.tableName, null);
    if (es == null) return;
    List<CloudFileEntity> temp =
        es.map((f) => CloudFileEntity.fromJson(f)).toList();
    _root = temp.firstWhere((t) => t.id == 0);
    _entities = temp;
  }

  // 增加
  Future<CloudFileEntity> insertCloudFile(CloudFileEntity entity) async {
    CloudFileEntity result = entity;
    _entities.add(result); // 更新缓存
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

  Future<bool> renameFile(int id, String newName) async {
    CloudFileEntity entity = getEntityById(id);
    if (entity == null) return false;

    bool success = await CloudFileHandle.renameFile(id, newName);
    if (!success) return false;
    // 文件重命名，只需要更新名字
    if (!entity.isFolder()) {
      entity.fileName =
          newName + FileUtil.ext(entity.fileName); // update memory
      await DBManager.instance.update(
          CloudFileEntity.tableName, entity, MapEntry('id', id)); // update db
    } else {
      // 文件夹重命名，更新名字，还要更新路径，太麻烦了，直接全量刷新
      await reflashCloudFileList();
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
    if (!success) return false;
    // 文件删除，只需要删除一个文件
    if (!entity.isFolder()) {
      _entities.remove(entity); // 删除缓存
      await DBManager.instance.delete(
          CloudFileEntity.tableName, {'id': entity.id.toString()}); // 删除DB
    } else {
      await reflashCloudFileList();
    }
    return success;
  }

  Future newFolder(int pid, String name) async {
    CloudFileEntity entity = await CloudFileHandle.newFolder(pid, name);
    return entity != null;
  }

  Future<bool> downloadFile(List<CloudFileEntity> es) {
    es.forEach((e) async {
      DownloadTask task = DownloadTask(
          id: e.id,
          fileName: e.fileName,
          path: FileUtil.getDownloadFilePath(e),
          token: CancelToken());
      TranslateManager.instant().addDoingTask(task);
      await CloudFileHandle.downloadOneFile(task);
    });
  }

  Future<bool> uploadFile(int pid, List<String> paths) async {
    paths.forEach((f) async {
      UploadTask task = UploadTask(path: f, pid: pid, token: CancelToken());
      TranslateManager.instant().addDownTask(task);
      await CloudFileHandle.uploadOneFile(task);
    });
  }
}
