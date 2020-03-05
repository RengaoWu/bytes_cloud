import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhotoPushRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PhotoPushRouteState();
  }
}

class PhotoPushRouteState extends State<PhotoPushRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('上传照片'),
      ),
      body: Center(
        child: Text('上传照片'),
      ),
    );
  }
}
