import 'dart:convert';

import 'package:bytes_cloud/http/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RemoteRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RemoteRouteState();
  }
}

class RemoteFileEntity {
  String fileName = '';
  int id;
  int parentId;
  String pathRoot;
  int size;
  String type; // dir
  int uid;
  dynamic uploadTime;
  RemoteFileEntity.fromJson(Map map) {
    fileName = map['filename'];
    id = map['id'];
    parentId = map['parent_id'];
    pathRoot = map['path_root'];
    size = map['size'];
    uid = map['uid'];
    uploadTime = map['upload_time'];
  }
}

class RemoteRouteState extends State<RemoteRoute>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<RemoteFileEntity> entities = [];
  @override
  void initState() {
    super.initState();
  }
//  I/flutter (30123): filename : root
//  I/flutter (30123): id : 0
//  I/flutter (30123): parent_id : -1
//  I/flutter (30123): path_root :
//  I/flutter (30123): size : 0
//  I/flutter (30123): type_of_node : dir
//  I/flutter (30123): uid : 0
//  I/flutter (30123): upload_time : null

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.widgets),
          onPressed: () {
            // http://116.62.177.146:5000/api/file/all?curUid=0
            httpGet('/api/file/all', {'curUid': '0'}).then((value) {
              List maps = value['data'];
              maps.forEach((json) {
                entities.add(RemoteFileEntity.fromJson(json));
              });
              setState(() {});
            });
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.transform),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {},
          )
        ],
      ),
      body: ListView.builder(
          itemCount: entities.length,
          itemBuilder: (BuildContext context, int index) {
            String ss = entities[index].fileName;
            if (ss == null) {
              ss = '';
            }
            return ListTile(
              title: Text(ss),
            );
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    print('remote route dispose');
  }

  @override
  void deactivate() {
    super.deactivate();
    print('remote route deactivate');
  }
}
