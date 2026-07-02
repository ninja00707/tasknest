class Env {
  static bool isLive = false;

  /// Override this if your IIS hostname (e.g. "loop") doesn't resolve on clients.
  /// Set to e.g. 'http://10.100.0.23:82' to force a fixed IP for WebSocket.
  static String? socketHostOverride;

  static String get baseUrl {
    if (isLive) {
      return '/api/';
    } else {
      return 'http://localhost:5050/api/';
    }
  }

  static String get socketUrl {
    if (isLive) {
      if (socketHostOverride != null) return socketHostOverride!;
      return '';
    } else {
      return 'http://localhost:5050';
    }
  }
}
