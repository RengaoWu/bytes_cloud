import 'package:shared_preferences/shared_preferences.dart';

class SP {
  static SharedPreferences sp;
  // 方便起见，账号密码暂时保存在SP中
  static const KEY_ACCOUNT = "KEY_ACCOUNT";
  static const KEY_PASSWORD = "KEY_PASSWORD";

  // downloaded finished key
  static const KEY_DOWNLOADED = "DOWNLOADED_ID";

  // auto sync switch
  static const KEY_SYNC_QQ = 'KEY_SYNC_QQ';
  static const KEY_SYNC_WX = 'KEY_SYNC_WX';
  static const KEY_SYNC_IMAGE = 'KEY_SYNC_IMAGE';
  static const KEY_TRANSLATE_ONLY_IN_GPRS = 'KEY_TRANSLATE_ONLY_IN_GPRS';
  static const KEY_SHOW_HIDDEN_FILE = 'KEY_SHOW_HIDDEN_FILE';
  static const KEY_NICK_NAME = 'KEY_NICK_NAME';

  static String downloadedKey(String id) => '$KEY_DOWNLOADED $id';

  static Future<SharedPreferences> getSp() async {
    return SharedPreferences.getInstance();
  }

  static setString(String key, String value) {
    sp.setString(key, value);
  }

  static getString(String key, String def) {
    if (!sp.containsKey(key)) return def;
    String value = sp.getString(key);
    return value == null ? def : value;
  }

  static setBool(String key, bool value) {
    sp.setBool(key, value);
  }

  static getBool(String key, bool def) {
    if (!sp.containsKey(key)) return def;
    if (sp == null) {
      print('hhhhhhhh');
    }
    bool value = sp.getBool(key);
    return value == null ? def : value;
  }

  static setInt(String key, int value) {
    sp.setInt(key, value);
  }

  static getInt(String key, int def) {
    if (!sp.containsKey(key)) return def;
    int value = sp.getInt(key);
    return value == null ? def : value;
  }

  static setArray(String key, List<String> value) {
    sp.setStringList(key, value);
  }

  static getArray(String key, List<String> def) {
    if (!sp.containsKey(key)) return def;
    return sp.getStringList(key);
  }
}
