class JsonUtil {
  static String toJson(List<String> list) {
    String json = '[';
    for (int i = 0; i < list.length; i++) {
      if (i < list.length - 1) {
        json += '"${list[i]}",';
      } else {
        json += '"${list[i]}"';
      }
    }
    return json += ']';
  }
}
