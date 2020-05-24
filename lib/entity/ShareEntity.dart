import 'package:bytes_cloud/core/http/http.dart';
import 'package:bytes_cloud/core/manager/UserManager.dart';
import 'package:bytes_cloud/entity/entitys.dart';

//"file_id": 4,
//"share_begin_time": 1587707753,
//"share_end_time": 1588312553,
//"share_id": 2,
//"share_token": "ga8o",
//"share_url": "10t676r"
class ShareEntity extends Entity {
  int shareID;
  int fileID;
  int beginTime;
  int endTime;
  String filename;
  String shareToken;
  String shareURL;
  String qrCodeFile = '';
  static const String ORDER_BY_BEGIN_TIME_DESC = ' share_begin_time desc';
  static const String ORDER_BY_END_TIME = ' share_end_time ';
  static const String ORDER_BY_END_TIME_DESC = ' share_end_time desc';
  static String get tableName => 'ShareEntity' + UserManager.instance().userName;
  static String get SQL_SHARE_CREATE => '''
			      CREATE TABLE ${tableName} (
            file_id INTEGER, 
            share_id INTEGER PRIMARY KEY, 
            share_begin_time INTEGER, 
            share_end_time INTEGER,
            filename TEXT, 
            share_token TEXT,
            share_url TEXT,
            qrCodeFile TEXT)
		''';
  ShareEntity.fromMap(Map<String, dynamic> map) : super.fromMap(map) {
    fileID = map['file_id'];
    shareID = map['share_id'];
    beginTime = map['share_begin_time'];
    endTime = map['share_end_time'];
    shareToken = map['share_token'];
    shareURL = map['share_url'];
    filename = map['filename'];
    qrCodeFile = map['qrCodeFile'] == null ? '' : map['qrCodeFile'];
    if (DateTime.fromMillisecondsSinceEpoch(beginTime).year < 2020) {
      beginTime *= 1000;
      endTime *= 1000;
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'file_id': fileID,
      'share_id': shareID,
      'share_begin_time': beginTime,
      'share_end_time': endTime,
      'share_token': shareToken,
      'share_url': shareURL,
      'qrCodeFile': qrCodeFile,
      'filename': filename,
    };
  }

  String get getShareDownloadURL =>
      host +
      HTTP_POST_SHARE_FILE_DOWNLOAD +
      '/${shareURL}' +
      '?share_token=$shareToken' +
      '&filename=$filename';

  /// 没有token
  String get getShareDownloadURLWithoutToken =>
      host +
          HTTP_POST_SHARE_FILE_DOWNLOAD +
          '/${shareURL}' +
          '?share_token=' +
          '&filename=$filename';

  String get getShareContent{
    String link = host + HTTP_POST_SHARE_FILE_DOWNLOAD + '/${shareURL}?share_token=';
    String result = '来自BytesCloud的分享 ${link}';
    if(shareToken != null) {
      return result + ', 提取码: $shareToken';
    } else {
      return result;
    }
  }
}
