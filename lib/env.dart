class Env {
  static bool isLive = false;

  static String get baseUrl {
    if (isLive) {
      return '/api/';
    } else {
      return 'http://localhost:5050/api/';
    }
  }

  static String get socketUrl {
    if (isLive) {
      return '';
    } else {
      return 'http://localhost:5050';
    }
  }
}
