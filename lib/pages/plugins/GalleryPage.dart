import 'dart:io';

import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class PhotoGalleryPage extends StatefulWidget {
  final Map<String, dynamic> map;
  PhotoGalleryPage(this.map);
  @override
  State<StatefulWidget> createState() {
    return PhotoGalleryPageState(map);
  }
}

class PhotoGalleryPageState extends State<PhotoGalleryPage> {
  final Map<String, dynamic> arg;
  List<FileSystemEntity> images = [];
  int currentIndex = 0;
  PhotoGalleryPageState(this.arg) {
    List<FileSystemEntity> files = arg['files'];
    FileSystemEntity currentImage = arg['current'];
    files.forEach((f) {
      if (FileUtil.isImage(f.path)) {
        images.add(f);
        if (currentImage.path == f.path) {
          currentIndex = images.length - 1;
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(child: galleryView()),
          Align(
            alignment: Alignment.center,
            child: boldText('$currentIndex/${images.length}'),
          ),
        ],
      ),
    );
  }

  galleryView() {
    return ExtendedImageGesturePageView.builder(
      itemBuilder: (BuildContext context, int index) {
        var item = images[index];
        Widget image = ExtendedImage.file(
          item,
          fit: BoxFit.contain,
          mode: ExtendedImageMode.gesture,
        );
        image = Container(
          child: image,
          padding: EdgeInsets.all(5.0),
        );
        if (index == currentIndex) {
          return Hero(
            tag: item.path,
            child: image,
          );
        } else {
          return image;
        }
      },
      itemCount: images.length,
      onPageChanged: (int index) {
        setState(() {
          currentIndex = index;
        });
        //rebuild.add(index);
      },
      controller: PageController(
        initialPage: currentIndex,
      ),
      scrollDirection: Axis.horizontal,
    );
  }
}
