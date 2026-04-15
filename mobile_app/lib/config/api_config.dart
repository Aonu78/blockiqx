class ApiConfig {
  static const String baseUrl = 'http://YOUR_SERVER_IP:5000/api';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = '$baseUrl/login';
  static const String staffLogin = '$baseUrl/staff/login';
  static const String logout = '$baseUrl/logout';

  // ── Community / Guest ─────────────────────────────────────────────────────
  static const String submitReport = '$baseUrl/reports';
  static const String nearbyResources = '$baseUrl/reports/nearby';

  // ── Staff ─────────────────────────────────────────────────────────────────
  static const String staffReports = '$baseUrl/staff/reports';
  static String staffReportDetail(int id) => '$baseUrl/staff/reports/$id';
  static String updateReport(int id) => '$baseUrl/staff/reports/$id';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const String adminMapView = '$baseUrl/admin/analytics/map-view';

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
