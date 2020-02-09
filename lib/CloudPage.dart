import 'package:bytes_cloud/FileManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'EventBusUtil.dart';
import 'SearchRoute.dart';

class CloudRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CloudRouteState();
  }
}

class CloudRouteState extends State<CloudRoute> {
  static const String prefix = "SD:";
  static String path = "";
  @override
  void initState() {
    path = prefix;
    super.initState();
    GlobalEventBus().event.on<FilePathEvent>().listen((event) {
      if (mounted) {
        setState(() {
          path = prefix + event.path;
          print("CloudPage " + path);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$path'),
        ),
        body: Column(
          children: <Widget>[
            getSearchWidget(),
            Expanded(child: getFileListWidget())
          ],
        ));
  }

  Widget getSearchWidget() {
    return Center(
        child: Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                showSearch(context: context, delegate: SearchBarDelegate());
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  Text(
                    'Search',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.sort,
            color: Colors.grey,
          )
        ],
      ),
    ));
  }

  Widget getFileListWidget() {
    return FileManager();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
