class Env {
  static bool isLive = true;

  /// Backend API URL (set to your Railway / production backend)
  static String? backendUrl = 'https://tasknest-backend-production.up.railway.app';

  static String get baseUrl {
    if (isLive && backendUrl != null) {
      return '$backendUrl/api/';
    } else if (isLive) {
      return '/api/';
    } else {
      return 'http://localhost:5050/api/';
    }
  }

  static String get socketUrl {
    if (isLive && backendUrl != null) {
      return backendUrl!;
    } else if (isLive) {
      return '';
    } else {
      return 'http://localhost:5050';
    }
  }
}
