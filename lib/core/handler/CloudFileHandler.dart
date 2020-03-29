import 'dart:typed_data';

import 'package:bytes_cloud/core/manager/TranslateManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/http/http.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:dio/dio.dart';

class CloudFileHandle {
  // 获取所有的目录信息
  static Future<List<CloudFileEntity>> refreshCloudFileList() async {
    try {
      Map<String, dynamic> rsp = await httpGet(HTTP_GET_ALL_FILES);
      print('CloudFileHandle#refreshCloudFileList ${rsp.toString()}');
      if (rsp['code'] != 0) {
        return null;
      }
      List maps = rsp['data']['files'];
      List<CloudFileEntity> result = [];
      maps.forEach((json) {
        if (json['filename'] != null) {
          result.add(CloudFileEntity.fromMap(json));
        }
      });
      return result;
    } catch (e) {
      print('refreshCloudFileList ${e.toString()}');
      return null;
    }
  }

  static Future<CloudFileEntity> newFolder(int curId, String folderName) async {
    Map<String, dynamic> rsp;
    // 网络创建
    rsp = await httpPost(HTTP_POST_NEW_FOLDER,
        form: {'curId': curId, 'foldername': folderName});
    print('CloudFileHandler newFolder ${rsp.toString()}');
    if (rsp['code'] != 0) return null;
    return CloudFileEntity.fromMap(rsp['data']['file']);
  }

  static Future<bool> renameFile(int id, String newName) async {
    var resp = await httpPost(
      HTTP_POST_RENAME,
      form: {
        'id': id,
        'newName': newName,
      },
    );
    return resp['code'] == 0;
  }

  static Future<bool> deleteFile(int id) async {
    var resp = await httpGet(
      HTTP_GET_DELETE,
      params: {
        'id': id,
      },
    );
    print('deleteFile id = ${id} resp = ${resp.toString()}');
    return resp['code'] == 0;
  }

  static Future<CloudFileEntity> uploadOneFile(UploadTask task) async {
    int lastTime = DateTime.now().millisecondsSinceEpoch;
    var resp = await httpPost(HTTP_POST_A_FILE, call: (sent, total) {
      print('uploadOneFile ${sent} / ${total}');
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - lastTime > 500) {
        task.v = 1000 * ((sent - task.sent) / (currentTime - lastTime));
        lastTime = currentTime;
      }
      print('uploadOneFile v = ${task.v}');
      task.sent = sent;
      task.total = total;
      TranslateManager.instant().uploadTask.update(task, (t) => t == task);
    }, form: {
      'curId': task.pid,
      'file': await MultipartFile.fromFile(task.path,
          filename: FileUtil.getFileNameWithExt(task.path)),
    });
    print('uploadOneFile ${resp.toString()}');
    if (resp['code'] == 0)
      return CloudFileEntity.fromMap(resp['data']['file']);
    else
      return null;
  }

  static Future downloadOneFile(DownloadTask task) async {
    int lastTime = DateTime.now().millisecondsSinceEpoch;
    Response<ResponseBody> resp = await httpDownload(
        HTTP_POST_DOWNLOAD_FILE, {'id': task.id}, task.path, (sent, total) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - lastTime > 500) {
        task.v = 1000 * ((sent - task.sent) / (currentTime - lastTime));
        lastTime = currentTime;
      }
      lastTime = currentTime;
      task.sent = sent;
      task.total = total;
      TranslateManager.instant().downloadTask.update(task, (t) => t == task);
    });
    if (resp.statusCode == 200) {
      print('下载请求成功');
    }
  }
}
