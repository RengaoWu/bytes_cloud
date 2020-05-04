import 'dart:io';

import 'package:bytes_cloud/core/Config.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/IoslateMethods.dart';
import 'package:bytes_cloud/utils/ThumbUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SysImageSelectorPage extends StatefulWidget {
  final Map<String, dynamic> args;
  SysImageSelectorPage(this.args);
  @override
  State<StatefulWidget> createState() {
    return SysImageSelectorPageState();
  }
}

class SysImageSelectorPageState extends State<SysImageSelectorPage> {
  String root;
  String rootName;
  List<FileSystemEntity> files;
  List<FileSystemEntity> uiData;
  List<String> exts = [];
  double imageSize;
  @override
  void initState() {
    super.initState();
    root = widget.args['root'];
    rootName = widget.args['rootName'];
    imageSize = UI.dpi2px(UI.DISPLAY_WIDTH / 2);
    exts.addAll(Config.imagesExt);
    exts.addAll(Config.videoExtension2Type.keys);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(rootName),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cloud_upload),
            onPressed: () {},
          )
        ],
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: computeGetAllFiles(roots: [root], keys: exts, isExt: true),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            files = snapshot.data;
            return gridImageView();
          }
          return Center(
            child: Text('error'),
          );
        },
      ),
    );
  }

  gridImageView() {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: files.length,
      itemBuilder: (BuildContext context, int index) {
        return loadImage(files[index]);
      },
      staggeredTileBuilder: (int index) {
        return new StaggeredTile.count(1, 1);
      },
    );
  }

  loadImage(FileSystemEntity entity) {
    if (FileUtil.isImage(entity.path)) {
      return Image.file(
        entity,
        cacheWidth: imageSize.toInt(),
      );
    } else {
      return getThumbWidget(entity.path, width: imageSize, height: imageSize);
    }
  }
}

class _ViewHolder {
  static const CHILD = 0;
  static const GROUP = 1;
  int type = 0; // type 0 is child, type 1 is group name
  FileSystemEntity entity;
  DateTime dataTime;
  _ViewHolder(this.entity, this.dataTime, this.type);
}
