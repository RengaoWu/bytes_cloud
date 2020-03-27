import 'dart:typed_data';

import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/core/manager/TranslateManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/http/http.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/SPWrapper.dart';
import 'package:dio/dio.dart';

class CloudFileHandle {
  // 获取所有的目录信息
  static Future<List<CloudFileEntity>> refreshCloudFileList() async {
    try {
      Map<String, dynamic> rsp =
          await httpGet(HTTP_GET_ALL_FILES, params: {'curUid': '0'});
      List maps = rsp['data'];
      List<CloudFileEntity> result = [];
      maps.forEach((json) {
        if (json['filename'] != null) {
          result.add(CloudFileEntity.fromJson(json));
        }
      });
      return result;
    } catch (e) {
      return null;
    }
  }

  static Future<CloudFileEntity> newFolder(int curId, String folderName) async {
    Map<String, dynamic> rsp;
    // 网络创建
    rsp = await httpPost(HTTP_POST_NEW_FOLDER,
        form: {'curId': curId, 'foldername': folderName});
    if (rsp['code'] != 0) return null;
    return CloudFileEntity.fromJson(rsp['data']);
  }

  static Future<bool> renameFile(int id, String newName) async {
    var resp = await httpPost(
      HTTP_POST_RENAME,
      params: {
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
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      task.v = 1000 * ((sent - task.sent) / (currentTime - lastTime));
      task.sent = sent;
      task.total = total;
      lastTime = currentTime;
    }, form: {
      'curId': task.pid,
      'file': await MultipartFile.fromFile(task.path,
          filename: FileUtil.getFileNameWithExt(task.path)),
    });
    print('uploadOneFile ${resp.toString()}');
    if (resp['code'] == 0)
      return CloudFileEntity.fromJson(resp['data']);
    else
      return null;
  }

  static Future downloadOneFile(DownloadTask task) async {
    int lastTime = DateTime.now().millisecondsSinceEpoch;
    Response<ResponseBody> resp = await httpDownload(
        HTTP_POST_DOWNLOAD_FILE, {'id': task.id}, task.path, (sent, total) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      task.v = 1000 * ((sent - task.sent) / (currentTime - lastTime));
      lastTime = currentTime;
      task.sent = sent;
      task.total = total;
    });
    if (resp.statusCode == 200) {
      print('下载请求成功');
    }
  }
}
