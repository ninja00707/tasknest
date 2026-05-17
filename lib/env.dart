class Env {
  static bool isLive = false;

  static String get baseUrl {
    if (isLive) {
      return 'https://your-production-api.com/api/';
    } else {
      return 'http://localhost:5000/api/';
    }
  }
}
