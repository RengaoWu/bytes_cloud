import 'dart:io';

import 'package:bytes_cloud/FileManager.dart';
import 'package:bytes_cloud/HomeRout.dart';
import 'package:bytes_cloud/test/ViewPageTest.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'common.dart';

// void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: HomeRoute(),
      home: HomeRoute(),
      // home: BgWidget(),
    );
  }
}

void main() async {
  Future<void> getSDCardDir() async {
    Common().sDCardDir = (await getExternalStorageDirectory()).path;
  }

  Future<void> getPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      }
      await getSDCardDir();
    } else if (Platform.isIOS) {
      await getSDCardDir();
    }
  }

  WidgetsFlutterBinding.ensureInitialized();
  // Permission check
  // [initializeDateFormatting("zh-CN", "")
  Future.wait([initializeDateFormatting("zh-CN", ""), getPermission()])
      .then((result) {
    runApp(MyApp());
  });
}
