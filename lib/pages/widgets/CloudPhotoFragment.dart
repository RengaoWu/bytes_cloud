import 'dart:collection';
import 'dart:io';

import 'package:bytes_cloud/core/common.dart';
import 'package:bytes_cloud/core/handler/CloudFileHandler.dart';
import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/utils/SPWrapper.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:dio/dio.dart';
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
    print('cloud photo fragment initState');
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
    bool flag = SPUtil.getBool(SPUtil.downloadedKey(holder.entity.id), false);
    FileSystemEntity file =
        File(Common().appDownload + '/' + holder.entity.fileName);
    if (flag && file.existsSync()) {
      return InkWell(
          onTap: () => UI.openFile(context, file),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            width: UI.DISPLAY_WIDTH / 4,
            height: UI.DISPLAY_WIDTH / 4,
          ));
    } else {
      if (file.existsSync()) {
        file.deleteSync();
        print('delete undownloaded file');
      }
      CancelToken token = CancelToken();
      tokens.add(token);
      return FutureBuilder(
        future: CloudFileHandle.downloadOneFile(holder.entity, token),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return UnconstrainedBox(
                child: SizedBox(
                    width: 48, height: 48, child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return SizedBox();
          }
          return InkWell(
              onTap: () => UI.openFile(context, file),
              child: Image.file(
                file,
                fit: BoxFit.cover,
                width: UI.DISPLAY_WIDTH / 4,
                height: UI.DISPLAY_WIDTH / 4,
              ));
        },
      );
    }
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
