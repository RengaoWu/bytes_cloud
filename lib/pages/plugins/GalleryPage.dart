import 'dart:io';

import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/http/http.dart';
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
  bool _isNative;
  // native data
  List<FileSystemEntity> nativeImages = [];
  // network data
  List<CloudFileEntity> networkImages = [];

  int currentIndex = 0;
  int totalSize = 0;

  PhotoGalleryPageState(this.arg) {
    if (arg['current'] is CloudFileEntity) {
      _isNative = false;
      initNetworkMode();
      totalSize = networkImages.length;
    } else {
      _isNative = true;
      initNativeMode();
      totalSize = nativeImages.length;
    }
  }
  double dealtX;
  double dealtY;

  initNativeMode() {
    List<FileSystemEntity> files = arg['files'];
    FileSystemEntity currentImage = arg['current'];
    if (files == null) files = [currentImage];
    files.forEach((f) {
      if (FileUtil.isImage(f.path)) {
        nativeImages.add(f);
        if (currentImage.path == f.path) {
          currentIndex = nativeImages.length - 1;
        }
      }
    });
  }

  initNetworkMode() {
    CloudFileEntity currentImage = arg['current'];
    List<CloudFileEntity> files = arg['files'];
    if (files == null) networkImages = [currentImage];
    files.forEach((f) {
      if (FileUtil.isImage(f.fileName)) {
        print('${currentImage.id} ${f.id}');
        networkImages.add(f);
        if (currentImage.id == f.id) {
          currentIndex = networkImages.length - 1;
          print(currentIndex);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
              child: GestureDetector(
            child: _isNative ? nativeGalleryView() : networkGalleryView(),
            onVerticalDragEnd: (DragEndDetails details) {
              if (details.velocity.pixelsPerSecond.dy >
                  details.velocity.pixelsPerSecond.dx) {
                Navigator.pop(context);
                return;
              }
            },
          )),
          Align(
            alignment: Alignment.center,
            child: boldText('${currentIndex + 1}/${totalSize}'),
          ),
        ],
      ),
    );
  }

  nativeGalleryView() {
    return ExtendedImageGesturePageView.builder(
      itemBuilder: (BuildContext context, int index) {
        var item = nativeImages[index];
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
      itemCount: nativeImages.length,
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

  networkGalleryView() {
    return ExtendedImageGesturePageView.builder(
      itemBuilder: (BuildContext context, int index) {
        var item = networkImages[index];
        // check if downloaded
        Widget image;
        if (FileUtil.haveDownloaded(item)) {
          image = ExtendedImage.file(
            File(FileUtil.getDownloadFilePath(item)),
            fit: BoxFit.contain,
            mode: ExtendedImageMode.gesture,
          );
        } else {
          image = ExtendedImage.network(
            getPreviewUrl(item.id),
            fit: BoxFit.contain,
            mode: ExtendedImageMode.gesture,
            cache: true,
          );
        }
        return Hero(
          tag: item.id,
          child: Container(
            child: image,
            padding: EdgeInsets.all(5.0),
          ),
        );
      },
      itemCount: networkImages.length,
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
