import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

// https://github.com/flutterchina/dio/blob/master/README-ZH.md
var dio = Dio();
String host = "";

String generateUrl(String path, Map<String, String> map) {
  String url = host + path;
  if (map == null) return url;
  url += '?';
  map.forEach((String key, String value) {
    url = url + key + '=' + value + '&';
  });
  return url.substring(0, url.length - 1);
}

// GET
Future<String> httpGet(String path, Map<String, String> map) async {
  try {
    Response response = await Dio().get(generateUrl(path, map));
    return response.data;
  } catch (e) {
    return e.toString();
  }
}

// POST form-data
Future<String> httpPost(String path, Map<String, String> map) async {
  try {
    FormData data = FormData.fromMap(map);
    Response response = await dio.post(generateUrl(path, null), data: data);
    return response.data;
  } catch (e) {
    return e.toString();
  }
}

// post 多个文件
