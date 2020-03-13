import 'dart:io';

import 'package:bytes_cloud/common.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:thumbnails/thumbnails.dart';

import 'FileUtil.dart';

getThumbWidget(String path) {
  // from cache
  var thumb = _getThumbFromCache(path);
  if (thumb != null) {
    return _getImage(thumb);
  }
  // generate
  return FutureBuilder(
    future: _realGetThumb(Common().appCache, path),
    //future: compute(_getThumb, {'path': path, 'appRoot': Common.appRoot}),
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
  String thumbnailFolder = Common().appCache;
  String thumbnailFolderPng =
      thumbnailFolder + '/' + FileUtil.getFileName(path) + '.png';
  if (File(thumbnailFolderPng).existsSync()) {
    print("YES");
    return thumbnailFolderPng;
  }
  print("NO");
  return null;
}

Future<String> _realGetThumb(String cachePath, String videoPath) async {
  return (await Constants.COMMON
      .invokeListMethod(Constants.getThumbnails, [cachePath, videoPath]))[0];
}
