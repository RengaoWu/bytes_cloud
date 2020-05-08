import 'package:bytes_cloud/core/http/FileShareHandler.dart';
import 'package:bytes_cloud/core/http/http.dart';
import 'package:bytes_cloud/core/manager/Manager.dart';
import 'package:bytes_cloud/entity/DownloadTask.dart';
import 'package:bytes_cloud/entity/ShareEntity.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'DBManager.dart';

/// [isShareURL] 保持一致
String getShareURL(ShareEntity entity) {
  return host +
      HTTP_POST_SHARE_FILE_DOWNLOAD +
      '/${entity.shareURL}' +
      '?share_token=${entity.shareToken}';
}

/// [getShareURL] 保持一直
bool isShareURL(String url) {
  if (url == null) return false;
  return url.startsWith(host + HTTP_POST_SHARE_FILE_DOWNLOAD) &&
      url.contains('?share_token=');
}

class ShareManager extends Manager {
  static ShareManager _manager;
  static ShareManager get instance => _getInstance();
  static ShareManager _getInstance() {
    if (_manager == null) {
      _manager = ShareManager._init();
    }
    return _manager;
  }

  ShareManager._init() {}
  @override
  destroy() {
    return null;
  }

  Future<ShareEntity> shareFile(int id, bool needToken, int day) async {
    ShareEntity entity = await FileShareHandler.shareFile(id, needToken, day);
    if (entity != null) {
      DBManager.instance.insert(ShareEntity.tableName, entity);
    }
    return entity;
  }

  Future<bool> deleteShareFile(ShareEntity entity) async {
    bool success = await FileShareHandler.delShareFile(entity.shareID);
    if (success != null) {
      DBManager.instance.delete(
          ShareEntity.tableName, {'share_id': entity.shareID.toString()});
    }
    return success;
  }

  Future<bool> downloadShareFile(Uri uri) async {
    print('downloadShareFile ' + uri.toString());
    String shareUrl = uri.pathSegments.last;
    Map<String, String> params = uri.queryParameters;
    String filename = params['filename'];
    String token = params['share_token'];
    String path = FileUtil.getShareDownloadFilePath(filename);
    bool success = await FileShareHandler.downloadShareFile(DownloadTask(
        id: shareUrl, filename: filename, path: path, token: token));
    if (success) Fluttertoast.showToast(msg: '${filename}下载完成,保存到{$path}');
    return success;
  }
}
