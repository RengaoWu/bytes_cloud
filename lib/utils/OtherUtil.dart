import 'dart:io';

import 'package:bytes_cloud/core/common.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:flutter/cupertino.dart';

import 'FileUtil.dart';

convertTimeToString(DateTime dateTime) {
  return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
}

String toJson(List<String> list) {
  String json = '[';
  for (int i = 0; i < list.length; i++) {
    if (i < list.length - 1) {
      json += '"${list[i]}",';
    } else {
      json += '"${list[i]}"';
    }
  }
  return json += ']';
}

getThumbWidget(String path) {
  // from cache
  var thumb = _getThumbFromCache(path);
  if (thumb != null) {
    return _getImage(thumb);
  }
  // generate
  return FutureBuilder(
    future: _realGetThumb(Common().appCache, path),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.hasData) {
        return _getImage(snapshot.data);
      }
      return SizedBox(
        height: 200,
        width: 200,
      );
    },
  );
}

_getImage(String path) {
  return ClipRRect(
      //borderRadius: BorderRadius.circular(4),
      child: Image.file(
    File(path),
    width: 200,
    height: 200,
    fit: BoxFit.cover,
  ));
}

_getThumbFromCache(String path) {
  print('_getThumbFromCache path = ' + path);
  String thumbnailFolder = Common().appCache;
  String thumbnailFolderPng =
      thumbnailFolder + '/' + FileUtil.getFileName(path) + '.png';
  if (File(thumbnailFolderPng).existsSync()) {
    return thumbnailFolderPng;
  }
  return null;
}

Future<String> _realGetThumb(String cachePath, String videoPath) async {
  return (await Constants.COMMON
      .invokeListMethod(Constants.getThumbnails, [cachePath, videoPath]))[0];
}
