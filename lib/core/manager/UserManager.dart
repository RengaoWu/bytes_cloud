import 'package:bytes_cloud/core/http/UserHandler.dart';

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
    return UserHandler.register(userName, password);
  }

  static Future login(String userName, String password) async {
    return UserHandler.login(userName, password);
  }

  static Future logout() async {
    return UserHandler.logout();
  }
}
