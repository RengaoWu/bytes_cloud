import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

// https://github.com/flutterchina/dio/blob/master/README-ZH.md

// http://116.62.177.146:5000/api/file/all?curUid=0
///
/// http://116.62.177.146:5000/api/file/upload?  name	folder1 Bodyfile 上传文件

String host = "http://116.62.177.146:5000"; // host
var dio = Dio(BaseOptions(baseUrl: host));

const String HTTP_GET_ALL_FILES = '/api/file/all';
const String HTTP_POST_A_FILE = '/api/file/upload';

// GET
Future<Map<String, dynamic>> httpGet(
    String path, Map<String, String> map) async {
  try {
    Response response = await dio.get(path, queryParameters: map);
    return response.data;
  } catch (e) {
    print(e.toString());
    return {'error': e.toString()};
  }
}

// POST form-data
Future<String> httpPost(String path,
    {Map<String, String> params = const {},
    Map<String, dynamic> form = const {},
    Function call}) async {
  try {
    FormData data = FormData.fromMap(form);
    Response response = await dio.post(path,
        queryParameters: params,
        data: data, onSendProgress: (int send, int total) {
      call(send, total);
    });
    return response.data;
  } catch (e) {
    return e.toString();
  }
}

// post 多个文件
