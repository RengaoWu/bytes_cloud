import 'package:bytes_cloud/http/http.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class UserManager {
  static UserManager _manager;
  static UserManager get manager => instance();
  static UserManager instance() {
    if (_manager == null) {
      _manager = UserManager._init();
    }
    return _manager;
  }

  UserManager._init();

  static Future<bool> register(String userName, String password) async {
    var rsp = await httpPost(HTTP_POST_REGISTER,
        form: {'email': userName, 'password': password});
    return rsp['code'] == 0;
  }

  static Future login(String userName, String password) async {
    var rsp = await httpPost(HTTP_POST_LOGIN,
        form: {'email': userName, 'password': password});
    print('login rsp ${rsp.toString()}');
    if (rsp['code'] == 0) {
      var cookieJar = CookieJar();
      dio.interceptors.add(CookieManager(cookieJar));
      cookieJar.saveFromResponse(Uri.parse(host), rsp);
      print('login success save cookie');
    }
    return rsp['code'] == 0;
  }
}
