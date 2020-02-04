// 提供五套可选主题色
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/model.dart';

const _themes = <MaterialColor>[
    Colors.blue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.red,
];

class Global {
    static SharedPreferences _prefs;
    static Profile profile = Profile();
    // 网络缓存对象
    // static NetCache netCache = NetCache();

    // 可选的主题列表
    static List<MaterialColor> get themes => _themes;

    // 是否为release版
    static bool get isRelease => bool.fromEnvironment("dart.vm.product");

    //初始化全局信息，会在APP启动时执行
    static Future init() async {
        _prefs = await SharedPreferences.getInstance();
        var _profile = _prefs.getString("profile");
        if (_profile != null) {
            try {
                profile = Profile();
            } catch (e) {
                print(e);
            }
        }

//        // 如果没有缓存策略，设置默认缓存策略
//        profile.cache = profile.cache ?? CacheConfig()
//            ..enable = true
//            ..maxAge = 3600
//            ..maxCount = 100;

        //初始化网络请求相关配置
        //Git.init();
    }

    // 持久化Profile信息
    static saveProfile() => _prefs.setString("profile", "");
}

class ProfileChangeNotifier extends ChangeNotifier {
    Profile get _profile => Global.profile;

    @override
    void notifyListeners() {
        Global.saveProfile(); //保存Profile变更
        super.notifyListeners(); //通知依赖的Widget更新
    }
}

class UserModel extends ProfileChangeNotifier {
    User get user => _profile.user;

    // APP是否登录(如果有用户信息，则证明登录过)
    bool get isLogin => user != null;

    //用户信息发生变化，更新用户信息并通知依赖它的子孙Widgets更新
    set user(User user) {
        if (user?.login != _profile.user?.login) {
            _profile.lastLogin = _profile.user?.login;
            _profile.user = user;
            notifyListeners();
        }
    }
}

class ThemeModel extends ProfileChangeNotifier {
    // 获取当前主题，如果为设置主题，则默认使用蓝色主题
    ColorSwatch get theme => Global.themes.firstWhere((e) => e.value == _profile.theme, orElse: () => Colors.blue);

    // 主题改变后，通知其依赖项，新主题会立即生效
    set theme(ColorSwatch color) {
        if (color != theme) {
            _profile.theme = color[500].value;
            notifyListeners();
        }
    }
}