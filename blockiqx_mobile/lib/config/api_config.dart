class ApiConfig {
  static String get baseUrl {
    return 'https://deeppink-bat-985227.hostingersite.com/api'; // Use this for Android emulator
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  static String get register => '$baseUrl/register';
  static String get login => '$baseUrl/login';
  static String get staffLogin => '$baseUrl/staff/login';
  static String get logout => '$baseUrl/logout';

  // ── Community / Guest ─────────────────────────────────────────────────────
  static String get submitReport => '$baseUrl/reports';
  static String get nearbyResources => '$baseUrl/reports/nearby';

  // ── Staff ─────────────────────────────────────────────────────────────────
  static String get staffReports => '$baseUrl/staff/reports';
  static String staffReportDetail(int id) => '$baseUrl/staff/reports/$id';
  static String updateReport(int id) => '$baseUrl/staff/reports/$id';
  static String addReportNote(int id) => '$baseUrl/staff/reports/$id/notes';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static String get adminMapView => '$baseUrl/admin/analytics/map-view';

  // ── Headers ───────────────────────────────────────────────────────────────
  static Map<String, String> headers(String? token) {
    final map = <String, String>{'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      map['Authorization'] = 'Bearer $token';
    }
    return map;
  }

  static Map<String, String> jsonHeaders(String? token) {
    return {...headers(token), 'Content-Type': 'application/json'};
  }
}
