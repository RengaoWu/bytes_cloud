import 'dart:io';

import 'package:bytes_cloud/core/http/http.dart';
import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/core/manager/TranslateManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/entity/DownloadTask.dart';
import 'package:bytes_cloud/entity/ShareEntity.dart';
import 'package:bytes_cloud/utils/SPUtil.dart';
import 'package:dio/dio.dart';

class FileShareHandler {
  static Future<bool> downloadShareFile(DownloadTask task) async {
    int lastTime = DateTime.now().millisecondsSinceEpoch;
    int lastSent = 0;
    print('downloadShareFile' + task.toMap().toString());
    // 这里先用GET检查一下，如果需要token会返回code = 41
    var rsp = await httpGet(HTTP_POST_SHARE_FILE_DOWNLOAD + '/${task.id}',
        params: {'share_token': task.token});
    if(rsp.containsKey('code') && rsp['code'] != 0){ // code = 41 需要token
      print('FileShareHandler#downloadShareFile rsp = $rsp');
      return false;
    }
    // 这里再进行下载
    Response<ResponseBody> resp = await httpDownload(
        HTTP_POST_SHARE_FILE_DOWNLOAD + '/${task.id}',
        {'share_token': task.token},
        task.path, (sent, total) {
      task.sent = sent;
      task.total = total;
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - lastTime > 100) {
        task.v = 1000 * ((task.sent - lastSent) / (currentTime - lastTime));
        lastTime = currentTime;
        lastSent = task.sent;
      }
    });
    if (resp.statusCode == 200) {
      TranslateManager.instant().saveFinishedTask2DB(task);
      SP.setBool(SP.downloadedKey(task.id), true);
      print('下载请求成功');
      return true;
    }
    return false;
  }

  static Future<ShareEntity> shareFile(int id, bool needToken, int day) async {
    int token_required = needToken ? 1 : 0;
    day = day == -1 ? (365 * 10) : day;
    var rsp = await httpPost(HTTP_POST_SHARE_FILE,
        form: {'id': id, 'token_required': token_required, 'day': day});
    print('CloudFileHanlder shareFile rsp = ${rsp}');
    if (rsp['code'] == 0) {
      ShareEntity entity = ShareEntity.fromMap(rsp['data']['share']);
      entity.filename = CloudFileManager.instance().getEntityById(id).fileName;
      return entity;
    } else {
      print('CloudFileHanlder shareFile code != 0');
    }
    return null;
  }

  static Future<bool> delShareFile(int shareID) async {
    var rsp = await httpPost(HTTP_POST_DEL_SHARE, form: {'share_id': shareID});
    print('CloudFileHanlder delShareFile rsp = ${rsp}');
    return rsp['code'] == 0;
  }
}
