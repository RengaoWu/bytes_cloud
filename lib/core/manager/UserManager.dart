import 'package:bytes_cloud/core/http/UserHandler.dart';
import 'package:bytes_cloud/utils/SPUtil.dart';

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
  String userName;
  String get nickName => SP.getString( SP.KEY_NICK_NAME + userName, '来取个名字吧');

  static Future<bool> register(String userName, String password) async {
    return UserHandler.register(userName, password);
  }

  static Future login(String userName, String password) async {
    UserManager.instance().userName = userName;
    return UserHandler.login(userName, password);
  }

  static Future logout() async {
    return UserHandler.logout();
  }

  modifyNickName(String newName){
    SP.setString(SP.KEY_NICK_NAME + userName, newName);
  }
}
