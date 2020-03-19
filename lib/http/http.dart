import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

// https://github.com/flutterchina/dio/blob/master/README-ZH.md
String host = "http://116.62.177.146:5000"; // host
var dio = Dio(BaseOptions(baseUrl: host));

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

//// POST form-data
//Future<String> httpPost(String path, Map<String, String> map) async {
//  try {
//    FormData data = FormData.fromMap(map);
//    Response response = await dio.post(path, data: data);
//    return response.data;
//  } catch (e) {
//    return e.toString();
//  }
//}

// post 多个文件
