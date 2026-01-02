class AppConfig {
  /// Jalankan:
  /// flutter run --dart-define=API_BASE_URL=http://localhost
  /// Build:
  /// flutter build apk --dart-define=API_BASE_URL=https://api.domainmu.com
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost');

  /// Semua endpoint Laravel kamu ada di routes/api.php => prefix /api
  static String get apiBaseUrl => '${baseUrl.trim()}/api';

  /// Builder Uri yang AMAN (tidak double slash / tidak double /api)
  static Uri apiUri(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$apiBaseUrl$p');
  }
}
