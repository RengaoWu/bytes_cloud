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
    return Image.file(
      File(thumb),
      fit: BoxFit.cover,
      width: 400,
      height: 200,
    );
  }
  // generate
  return FutureBuilder(
    future: _realGetThumb(Common().appCache, path),
    //future: compute(_getThumb, {'path': path, 'appRoot': Common.appRoot}),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.hasData) {
        return Image.file(
          File(snapshot.data),
          fit: BoxFit.cover,
          width: 400,
          height: 200,
        );
      }
      return SizedBox(
        width: 400,
        height: 200,
      );
    },
  );
}

_getThumbFromCache(String path) {
  String thumbnailFolder = Common().appCache;
  String thumbnailFolderPng =
      thumbnailFolder + FileUtil.getFileName(path) + '.png';
  if (File(thumbnailFolderPng).existsSync()) {
    return thumbnailFolderPng;
  }
  return null;
}

Future<String> _realGetThumb(String cachePath, String videoPath) async {
  return (await Constants.COMMON
      .invokeListMethod(Constants.getThumbnails, [cachePath, videoPath]))[0];
//  return await Thumbnails.getThumbnail(
//      thumbnailFolder:
//          cachePath, // creates the specified path if it doesnt exist
//      videoFile: videoPath,
//      imageType: ThumbFormat.PNG,
//      quality: 10);
}
