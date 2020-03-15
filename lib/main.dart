import 'dart:io';

import 'package:bytes_cloud/core/common.dart';
import 'package:bytes_cloud/pages/HomeRout.dart';
import 'package:bytes_cloud/utils/SPWrapper.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
    // /storage/emulated/0/Android/data/com.bytescloud.bytes_cloud/files
    // Common().sDCardDir = (await getExternalStorageDirectory());
    print((await getExternalStorageDirectory()).path);
    Common.sd = '/storage/emulated/0/';
    Common.appRoot = (await getApplicationSupportDirectory()).path;
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
