import 'package:bytes_cloud/entity/entitys.dart';
import 'package:bytes_cloud/http/http.dart';

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
  String shareToken;
  String shareURL;
  String qrCodeFile = '';
  static const String ORDER_BY_BEGIN_TIME = ' share_begin_time ';
  static const String tableName = 'ShareEntity';
  static const String SQL_SHARE_CREATE = '''
			      CREATE TABLE ${tableName} (
            file_id INTEGER, 
            share_id INTEGER PRIMARY KEY, 
            share_begin_time INTEGER, 
            share_end_time INTEGER,
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
    };
  }

  String get getShareDownloadURL =>
      host +
      HTTP_POST_SHARE_FILE_DOWNLOAD +
      shareURL +
      '?share_token=' +
      shareToken;
}
