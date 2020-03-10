import 'dart:io';

import 'package:bytes_cloud/FileManager.dart';
import 'package:bytes_cloud/HomeRout.dart';
import 'package:bytes_cloud/SplashRoute.dart';
import 'package:bytes_cloud/test/HttpTest.dart';
import 'package:bytes_cloud/test/SliverAppBar.dart';
import 'package:bytes_cloud/test/ViewPageTest.dart';
import 'package:bytes_cloud/update/PhotoPushRoute.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/SPUtil.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NativeRoute.dart';
import 'common.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'NotoSansSC',
      ),
      home: HomeRoute(),
//      home: PhotoPushRoute(
//        type: 1,
//      ),
      // home: HttpTestRoute(),
      // home: LoginRoute(),
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
  Future.wait([
    initializeDateFormatting("zh-CN", ""),
    getPermission(),
    SPUtil.getSp()
  ]).then((result) {
    SPUtil.sp = result[2] as SharedPreferences;
    runApp(MyApp());
  });
}
