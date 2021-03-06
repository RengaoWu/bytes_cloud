import 'dart:io';

import 'package:bytes_cloud/core/Common.dart';
import 'package:bytes_cloud/core/Constants.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';

import 'FileUtil.dart';

getThumbWidget(String path, {double width = 200, double height = 200}) {
  print('getThumbWidget path = ${path}');
  // from cache
  var thumb = _getThumbFromCache(path);
  if (thumb != null) {
    return _getImage(thumb, width, height);
  }

  // 检查文件是否存在
  if(!File(path).existsSync()) {
    return ClipRRect(
        child: Image.asset(
          Constants.VIDEO,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ));
  }
  // generate
  return FutureBuilder(
    future: _realGetThumb(Common.instance.appCache, path),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.hasData) {
        return _getImage(snapshot.data, width, height);
      }
      return SizedBox(
        height: height,
        width: width,
      );
    },
  );
}

_getImage(String path, double width, double height) {
  return ClipRRect(
      //borderRadius: BorderRadius.circular(4),
      child: Image.file(
    File(path),
    width: width,
    height: height,
    cacheWidth: UI.dpi2px(width).toInt(),
    fit: BoxFit.cover,
  ));
}

_getThumbFromCache(String path) {
  print('_getThumbFromCache path = ' + path);
  String thumbnailFolder = Common.instance.appCache;
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
