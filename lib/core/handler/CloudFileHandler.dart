import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/core/manager/TranslateManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/http/http.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/SPWrapper.dart';
import 'package:dio/dio.dart';

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
    UploadTask task = UploadTask(path: path, token: CancelToken());
    TranslateManager.instant().addDownTask(task);
    int lastTime = DateTime.now().millisecondsSinceEpoch;
    var resp = await httpPost(HTTP_POST_A_FILE, call: (sent, total) {
      print('$sent / $total');
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      task.v = 1000 * ((sent - task.sent) / (currentTime - lastTime));
      lastTime = currentTime;
      task.sent = sent;
      task.total = total;
    }, form: {
      'curId': 0,
      'file': await MultipartFile.fromFile(path, filename: name),
    });
    print(resp.toString());
  }

  static Future downloadOneFile(CloudFileEntity entity, CancelToken cancelToken,
      {Function call}) async {
    print('downloadOneFile ${entity.id} ${entity.fileName}');
    // check file exist
    DownloadTask task = DownloadTask(
        id: entity.id,
        fileName: entity.fileName,
        path: FileUtil.getDownloadFilePath(entity),
        token: cancelToken);
    TranslateManager.instant().addDoingTask(task);
    int lastTime = DateTime.now().millisecondsSinceEpoch;
    print('--------- begin ${DateTime.now().toString()}');
    try {
      var resp = await httpDownload(
          HTTP_POST_DOWNLOAD_FILE, {'id': task.id}, task.path, (sent, total) {
        int currentTime = DateTime.now().millisecondsSinceEpoch;
        task.v = 1000 * ((sent - task.sent) / (currentTime - lastTime));
        lastTime = currentTime;
        task.sent = sent;
        task.total = total;
      });
      // download finished, 可能文件没有下载完成，但是
      print('download finished id ${task.id}');
      SPUtil.setBool(SPUtil.downloadedKey(task.id), true);
    } catch (e) {
      print(e.toString());
    }
    print('---------- end ${DateTime.now().toString()}');
  }
}
