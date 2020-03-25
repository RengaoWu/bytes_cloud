import 'dart:collection';
import 'dart:io';

import 'package:bytes_cloud/core/common.dart';
import 'package:bytes_cloud/core/handler/CloudFileHandler.dart';
import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/http/http.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/SPWrapper.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CloudPhotoFragment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CloudPhotoFragmentState();
  }
}

class _CloudPhotoFragmentState extends State<CloudPhotoFragment> {
  Widget photoView;
  List<CloudFileEntity> _entities = [];
  List<_ViewHolder> uiDate = [];
  List<CancelToken> tokens = [];

  @override
  void initState() {
    super.initState();
    _entities = CloudFileManager.instance().photos;
    _entities.sort((e1, e2) => e2.uploadTime - e1.uploadTime);
    for (int i = 0; i < _entities.length; i++) {
      CloudFileEntity e = _entities[i];
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(e.uploadTime);
      if (i == 0) {
        uiDate.add(_ViewHolder(null, dateTime, _ViewHolder.GROUP));
        uiDate.add(_ViewHolder(e, dateTime, _ViewHolder.CHILD));
      } else {
        DateTime last =
            DateTime.fromMillisecondsSinceEpoch(_entities[i - 1].uploadTime);
        if (last.day != dateTime.day ||
            last.month != dateTime.month ||
            last.year != dateTime.year) {
          uiDate.add(_ViewHolder(null, dateTime, _ViewHolder.GROUP));
        }
        uiDate.add(_ViewHolder(e, dateTime, _ViewHolder.CHILD));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('cloud photo fragment build');
    if (photoView != null) return photoView;
    photoView = StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: uiDate.length,
      itemBuilder: (BuildContext context, int index) {
        _ViewHolder holder = uiDate[index];
        if (holder.type == _ViewHolder.GROUP) {
          return UI.groupItemCard(holder.time, flag: 3);
        } else {
          return loadImage(holder);
        }
      },
      staggeredTileBuilder: (int index) {
        _ViewHolder holder = uiDate[index];
        if (holder.type == _ViewHolder.GROUP) {
          return new StaggeredTile.count(4, 0.5);
        } else {
          return new StaggeredTile.count(1, 1);
        }
      },
    );
    return photoView;
  }

  Widget loadImage(_ViewHolder holder) {
    print(holder.entity.fileName);
    FileSystemEntity file = File(FileUtil.getDownloadFilePath(holder.entity));
    Widget image;
    if (FileUtil.haveDownloaded(holder.entity)) {
      print('haveDownloaded');
      image = Image.file(
        file,
        fit: BoxFit.cover,
        width: UI.DISPLAY_WIDTH / 4,
        height: UI.DISPLAY_WIDTH / 4,
      );
    } else {
      print('haveDownloaded not');
      if (file.existsSync()) {
        file.deleteSync();
        print('delete undownloaded file');
      }
      image = ExtendedImage.network(
        getPreviewUrl(holder.entity.id, UI.dpi2px(UI.DISPLAY_WIDTH / 4),
            UI.dpi2px(UI.DISPLAY_WIDTH / 4)),
        width: UI.DISPLAY_WIDTH / 4,
        height: UI.DISPLAY_WIDTH / 4,
        fit: BoxFit.cover,
        cache: true,
      );
    }
    return InkWell(
      child: image,
      onTap: () {
        UI.openCloudFile(context, holder.entity, entities: _entities);
      },
    );
  }

  @override
  void deactivate() {
    super.deactivate();
  }
}

class _ViewHolder {
  static const int CHILD = 0;
  static const int GROUP = 1;
  int type = 0; // child or group
  DateTime time;
  CloudFileEntity entity;
  _ViewHolder(this.entity, this.time, this.type);
}
