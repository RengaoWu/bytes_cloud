import 'dart:io';

import 'package:bytes_cloud/entity/ShareEntity.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

// https://github.com/flutterchina/dio/blob/master/README-ZH.md

// http://116.62.177.146:5000/api/file/all?curUid=0
///
/// http://116.62.177.146:5000/api/file/upload?  name	folder1 Bodyfile 上传文件
///
/// http://116.62.177.146:5000/api/file/reName?id=1&newName=newFolderName 重命名
///
/// http://116.62.177.146:5000/api/file/preview?id=55 // 预览
///
/// http://116.62.177.146:5000/api/file/delete?id=1 删除
///
/// http://116.62.177.146:5000/api/register?email=test1@163.com&password=123456 注册
///
/// http://116.62.177.146:5000/api/logout? 登出
///
/// http://116.62.177.146/api/file/share?id=3&token_required=1&day=7 获取分享URL
///
/// http://116.62.177.146/api/file/share/download/1pc2bw6?share_token=de99  download share file
///

const String host = "http://116.62.177.146"; // host
Dio dio = Dio(BaseOptions(
    baseUrl: host, connectTimeout: Duration(hours: 1).inMilliseconds));

CookieJar cookieJar = CookieJar();

initHttp() {
  dio.interceptors.add(CookieManager(cookieJar));
}

getToken() {
  List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse(host));
  for (int i = 0; i < cookies.length; i++) {
    List<String> kvs = cookies[i].toString().split(';');
    for (int j = 0; j < kvs.length; j++) {
      var kv = kvs[j].split('=');
      if (kv[0].trim() == 'token') return kv[1].trim();
    }
  }
  return null;
}

const String HTTP_GET_ALL_FILES = '/api/file/all';
const String HTTP_POST_A_FILE = '/api/file/upload';
const String HTTP_POST_NEW_FOLDER = '/api/file/newFolder';
const String HTTP_POST_DOWNLOAD_FILE = '/api/file/download';
const String HTTP_POST_RENAME = '/api/file/reName';
const String HTTP_GET_DELETE = '/api/file/delete';
const String HTTP_GET_PREVIEW = '/api/file/preview';
const String HTTP_POST_REGISTER = '/api/register';
const String HTTP_POST_LOGIN = '/api/login';
const String HTTP_POST_LOGOUT = '/api/logout';
const String HTTP_POST_SHARE_FILE = '/api/file/share';
const String HTTP_POST_DEL_SHARE = '/api/file/share/cancel';
const String HTTP_POST_SHARE_FILE_DOWNLOAD = '/api/file/share/download';

// GET
Future<Map<String, dynamic>> httpGet(String path,
    {Map<String, dynamic> params}) async {
  try {
    Response response = await dio.get(path, queryParameters: params);
    return response.data;
  } catch (e) {
    print(e.toString());
    return {'error': e.toString()};
  }
}

// POST form-data
Future<dynamic> httpPost(String path,
    {Map<String, dynamic> params = const {},
    Map<String, dynamic> form = const {},
    Function call}) async {
  try {
    FormData data = FormData.fromMap(form);
    Response response = await dio.post(path,
        queryParameters: params,
        data: data, onSendProgress: (int send, int total) {
      if (call != null) call(send, total);
    });
    return response.data;
  } catch (e) {
    return {'error': e};
  }
}

// 下载文件
Future httpDownload(String path, Map<String, dynamic> args, String savePath,
    Function call) async {
  var rsp = await dio.download(path, savePath, queryParameters: args,
      onReceiveProgress: (download, total) {
    if (call != null) call(download, total);
  });
  return rsp;
}
// post 多个文件

String getDownloadUrl(int id) {
  return host + HTTP_POST_DOWNLOAD_FILE + '?id=$id';
}

String getShareURL(ShareEntity entity) {
  return host +
      HTTP_POST_SHARE_FILE_DOWNLOAD +
      entity.shareURL +
      '?share_token=' +
      entity.shareToken;
}

String getPreviewUrl(int id, double width, double height) {
  String url = host +
      HTTP_GET_PREVIEW +
      '?id=$id&width=${width.toInt()}&height=${height.toInt()}&token=${getToken()}';
  //print('getPreviewUrl $url');
  return url;
}
