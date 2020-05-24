import 'package:bytes_cloud/core/manager/DBManager.dart';
import 'package:bytes_cloud/core/manager/Manager.dart';
import 'package:bytes_cloud/entity/DownloadTask.dart';
import 'package:bytes_cloud/entity/TranslateTask.dart';
import 'package:bytes_cloud/entity/UploadTask.dart';

/// 文件上传和下载管理器

class TranslateManager extends Manager {
  List<DownloadTask> _downloads;
  List<DownloadTask> get downloads => _downloads;
  List<UploadTask> _uploads;
  List<UploadTask> get uploads => _uploads;

  static TranslateManager _manager;
  TranslateManager._init() {
    _downloads = [];
    _uploads = [];
    initFromDB().whenComplete(() {
      print('TranslateManager 初始化完成');
    });
  }

  static TranslateManager instant() {
    if (_manager == null) {
      _manager = TranslateManager._init();
    }
    return _manager;
  }

  @override
  initFromDB() async {
    List<Map> ds =
        await DBManager.instance.queryAll(DownloadTask.tableName);
    if (ds != null) {
      _downloads = ds.map((d) => DownloadTask.formMap(d)).toList();
    }
    List<Map> us =
        await DBManager.instance.queryAll(UploadTask.tableName);
    if (us != null) {
      _uploads = us.map((u) => UploadTask.formMap(u)).toList();
    }
  }

  // 目前只将完成的任务存入DB
  saveFinishedTask2DB(TranslateTask task) {
    if (task is UploadTask) {
      DBManager.instance.insert(UploadTask.tableName, task);
    } else if (task is DownloadTask) {
      DBManager.instance.insert(DownloadTask.tableName, task);
    }
  }

  @override
  destroy() {
    //_downloads
    //_uploads
    _manager = null;
  }
}
