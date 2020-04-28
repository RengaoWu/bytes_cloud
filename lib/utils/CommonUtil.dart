class CommonUtil {
  static String launchEmail(String email, String subject, String body) {
    return 'mailto:$email?subject=${subject}&body=$body';
  }
}
