import 'dart:io';

import 'package:bytes_cloud/core/Common.dart';
import 'package:bytes_cloud/core/http/http.dart';
import 'package:bytes_cloud/core/manager/DBManager.dart';
import 'package:bytes_cloud/pages/LoginPage.dart';
import 'package:bytes_cloud/utils/SPUtil.dart';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/Constants.dart';
import 'model/ThemeModel.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider.value(value: ThemeModel()),
      ],
      child: Consumer<ThemeModel>(
        builder: (BuildContext context, themeModel, Widget child) {
          return MaterialApp(
            theme: ThemeData(
              primarySwatch: themeModel.theme,
              fontFamily: 'NotoSansSC',
            ),
            //home: HomeRoute(), //应用主页
            home: LoginRoute(),
          );
        },
      ),
    );
  }
}

void main() async {
  Future<void> getSDCardDir() async {
    // /storage/emulated/0/Android/data/com.bytescloud.bytes_cloud/files
    // Common.instance.sDCardDir = (await getExternalStorageDirectory());
    print((await getExternalStorageDirectory()).path);
    Common.sd = '/storage/emulated/0/';
    Common.appRoot = (await getApplicationSupportDirectory()).path;
    var map = await Constants.COMMON.invokeMethod(Constants.getCardState);
    print(map);
    Common.allSize = map['total'];
    Common.availableSize = map['available'];
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

  // todo 这里要添加一个 SplashPage 用于初始化
  WidgetsFlutterBinding.ensureInitialized();
  // Permission check
  // fixme appid 还没有申请下来
  registerWxApi(
      appId: "wxd930ea5d5a228f5f",
      universalLink: "https://your.univerallink.com/link/");
  Future.wait([
    initializeDateFormatting("zh-CN", ""),
    getPermission(), // 初始化权限
    SP.getSp(), // 初始化 sp
  ]).then((result) {
    initHttp(); // init http, 添加cookie
    SP.sp = result[2] as SharedPreferences;
    runApp(MyApp());
  });
}
