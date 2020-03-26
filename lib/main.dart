import 'dart:io';

import 'package:bytes_cloud/core/common.dart';
import 'package:bytes_cloud/core/manager/CloudFileManager.dart';
import 'package:bytes_cloud/core/manager/DBManager.dart';
import 'package:bytes_cloud/pages/HomeRout.dart';
import 'package:bytes_cloud/pages/content/SettingPage.dart';
import 'package:bytes_cloud/utils/SPWrapper.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/handler/CloudFileHandler.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider.value(value: ThemeModel()),
//        ChangeNotifierProvider.value(value: UserModel()),
//        ChangeNotifierProvider.value(value: LocaleModel()),
      ],
      child: Consumer<ThemeModel>(
        builder: (BuildContext context, themeModel, Widget child) {
          return MaterialApp(
            theme: ThemeData(
              primarySwatch: themeModel.theme,
              fontFamily: 'NotoSansSC',
            ),
            home: HomeRoute(), //应用主页
          );
        },
      ),
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
    getPermission(), // 初始化权限
    SPUtil.getSp(), // 初始化 sp
  ]).then((result) {
    SPUtil.sp = result[2] as SharedPreferences;
    // DBManager 初始化
    DBManager.instance;
    // 请求云盘所有文件
    CloudFileManager.instance().reflashCloudFileList().whenComplete(() {
      print('云盘数据初始化完成');
    });

    runApp(MyApp());
  });
}
