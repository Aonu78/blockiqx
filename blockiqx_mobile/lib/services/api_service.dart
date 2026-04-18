import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiService {
  // ─── AUTH ─────────────────────────────────────────────────────────────────

  /// POST /api/register
  static Future<Map<String, dynamic>> signupUser({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.register),
            headers: ApiConfig.jsonHeaders(null),
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = _decode(response);
      if (response.statusCode == 201 || response.statusCode == 200) return data;
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final first = errors.values.first;
        throw ApiException(
            first is List ? first.first.toString() : first.toString(),
            statusCode: response.statusCode);
      }
      throw ApiException(data['message'] ?? 'Failed to create account.',
          statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Cannot connect to server. Check your API URL.');
    }
  }

  /// POST /api/login  — community user OR admin
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: ApiConfig.jsonHeaders(null),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = _decode(response);
      if (response.statusCode == 200) return data;
      throw ApiException(
          data['message'] ?? 'Invalid email or password.',
          statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Cannot connect to server. Check your API URL.');
    }
  }

  /// POST /api/staff/login
  static Future<Map<String, dynamic>> staffLogin(
      String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.staffLogin),
            headers: ApiConfig.jsonHeaders(null),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = _decode(response);
      if (response.statusCode == 200) return data;
      throw ApiException(
          data['message'] ?? 'Invalid staff credentials.',
          statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Cannot connect to server. Check your API URL.');
    }
  }

  /// POST /api/logout
  static Future<void> logout(String token) async {
    try {
      await http
          .post(Uri.parse(ApiConfig.logout),
              headers: ApiConfig.headers(token))
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  // ─── COMMUNITY / GUEST ────────────────────────────────────────────────────

  /// POST /api/reports
  static Future<Map<String, dynamic>> submitReport({
    String? token,
    String? email,
    String? phoneNumber,
    required String incidentType,
    required String description,
    required String location,
    double? latitude,
    double? longitude,
    bool isAnonymous = false,
    List<File>? mediaFiles,
  }) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(ApiConfig.submitReport));
      request.headers.addAll(ApiConfig.headers(token));

      if (email != null && email.isNotEmpty) request.fields['email'] = email;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        request.fields['phone_number'] = phoneNumber;
      }
      request.fields['incident_type'] = incidentType;
      request.fields['description'] = description;
      request.fields['location'] = location;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();
      request.fields['is_anonymous'] = isAnonymous ? '1' : '0';

      if (mediaFiles != null) {
        for (final file in mediaFiles) {
          request.files
              .add(await http.MultipartFile.fromPath('media[]', file.path));
        }
      }

      final streamed =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      final data = _decode(response);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return data;
      }
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final first = errors.values.first;
        throw ApiException(
            first is List ? first.first.toString() : first.toString(),
            statusCode: response.statusCode);
      }
      throw ApiException(data['message'] ?? 'Failed to submit report.',
          statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Cannot connect to server. Check your API URL.');
    }
  }

  /// GET /api/reports/nearby
  static Future<List<dynamic>> getNearbyResources(String token,
      {double? lat, double? lng}) async {
    try {
      final params = <String, String>{};
      if (lat != null) params['lat'] = lat.toString();
      if (lng != null) params['lng'] = lng.toString();

      final uri = Uri.parse(ApiConfig.nearbyResources)
          .replace(queryParameters: params);

      final response = await http
          .get(uri, headers: ApiConfig.headers(token))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
        if (data is Map && data['data'] != null) return data['data'];
        return [];
      }
      throw ApiException('Failed to fetch nearby resources.',
          statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Cannot connect to server. Check your API URL.');
    }
  }

  // ─── STAFF ────────────────────────────────────────────────────────────────

  /// GET /api/staff/reports
  static Future<List<dynamic>> getStaffReports(String token) async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.staffReports),
              headers: ApiConfig.headers(token))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
        if (data is Map) {
          if (data['data'] != null) return data['data'];
          if (data['reports'] != null) return data['reports'];
        }
        return [];
      }
      if (response.statusCode == 401) {
        throw ApiException('Session expired. Please log in again.',
            statusCode: 401);
      }
      throw ApiException('Failed to fetch assigned reports.',
          statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Cannot connect to server. Check your API URL.');
    }
  }

  /// GET /api/staff/reports/{id}
  static Future<Map<String, dynamic>> getStaffReportDetail(
      String token, int reportId) async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.staffReportDetail(reportId)),
              headers: ApiConfig.headers(token))
          .timeout(const Duration(seconds: 15));

      final data = _decode(response);
      if (response.statusCode == 200) {
        if (data['id'] != null) return data;
        if (data['report'] != null) return data['report'];
        return data;
      }
      if (response.statusCode == 401) {
        throw ApiException('Session expired. Please log in again.',
            statusCode: 401);
      }
      throw ApiException('Failed to fetch report details.',
          statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Cannot connect to server. Check your API URL.');
    }
  }

  /// PUT /api/staff/reports/{id}
  static Future<Map<String, dynamic>> updateReportStatus({
    required String token,
    required int reportId,
    required String status,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final body = <String, dynamic>{'status': status};
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;

      final response = await http
          .put(
            Uri.parse(ApiConfig.updateReport(reportId)),
            headers: ApiConfig.jsonHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      final data = _decode(response);
      if (response.statusCode == 200) return data;
      if (response.statusCode == 401) {
        throw ApiException('Session expired. Please log in again.',
            statusCode: 401);
      }
      throw ApiException(
          data['message'] ?? 'Failed to update report status.',
          statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Cannot connect to server. Check your API URL.');
    }
  }

  /// POST /api/staff/reports/{id}/notes
  static Future<Map<String, dynamic>> addReportNote({
    required String token,
    required int reportId,
    required String note,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.addReportNote(reportId)),
            headers: ApiConfig.jsonHeaders(token),
            body: jsonEncode({'notes': note}),
          )
          .timeout(const Duration(seconds: 15));

      final data = _decode(response);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return data;
      }
      if (response.statusCode == 401) {
        throw ApiException('Session expired. Please log in again.',
            statusCode: 401);
      }
      throw ApiException(data['message'] ?? 'Failed to add note.',
          statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Cannot connect to server. Check your API URL.');
    }
  }

  /// GET /api/notifications
  static Future<Map<String, dynamic>> getNotifications(String token) async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.notifications), headers: ApiConfig.headers(token))
          .timeout(const Duration(seconds: 15));

      final data = _decode(response);
      if (response.statusCode == 200) return data;
      if (response.statusCode == 401) {
        throw ApiException('Session expired. Please log in again.',
            statusCode: 401);
      }
      throw ApiException(data['message'] ?? 'Failed to fetch notifications.',
          statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Cannot connect to server. Check your API URL.');
    }
  }

  /// PUT /api/notifications/{id}/read
  static Future<void> markNotificationRead(String token, String notificationId) async {
    try {
      final response = await http
          .put(
            Uri.parse(ApiConfig.markNotificationRead(notificationId)),
            headers: ApiConfig.headers(token),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final data = _decode(response);
        throw ApiException(data['message'] ?? 'Failed to mark notification as read.',
            statusCode: response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Cannot connect to server. Check your API URL.');
    }
  }

  // ─── ADMIN ────────────────────────────────────────────────────────────────

  /// GET /api/admin/analytics/map-view
  static Future<Map<String, dynamic>> getAdminMapView(
    String token, {
    String? dateFrom,
    String? dateTo,
    String? status,
    String? incidentType,
    int? organizationId,
  }) async {
    try {
      final params = <String, String>{};
      if (dateFrom != null && dateFrom.isNotEmpty) params['date_from'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) params['date_to'] = dateTo;
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (incidentType != null && incidentType.isNotEmpty) {
        params['incident_type'] = incidentType;
      }
      if (organizationId != null) {
        params['organization_id'] = organizationId.toString();
      }

      final uri = Uri.parse(ApiConfig.adminMapView)
          .replace(queryParameters: params);

      final response = await http
          .get(uri, headers: ApiConfig.headers(token))
          .timeout(const Duration(seconds: 20));

      final data = _decode(response);
      if (response.statusCode == 200) return data;
      if (response.statusCode == 401) {
        throw ApiException('Session expired. Please log in again.',
            statusCode: 401);
      }
      if (response.statusCode == 403) {
        throw ApiException(
            'Access denied. Admin or super-admin role required.',
            statusCode: 403);
      }
      throw ApiException(
          data['message'] ?? 'Failed to fetch analytics data.',
          statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Cannot connect to server. Check your API URL.');
    }
  }

  // ─── HELPER ───────────────────────────────────────────────────────────────

  static Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    } catch (_) {
      return {'message': 'Unexpected response from server.'};
    }
  }
}
