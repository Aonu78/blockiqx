import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/staff.dart';
import '../services/api_service.dart';

enum AuthMode { none, user, staff, admin }

class AuthProvider with ChangeNotifier {
  String? _token;
  User? _user;
  Staff? _staff;
  AuthMode _mode = AuthMode.none;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  User? get user => _user;
  Staff? get staff => _staff;
  AuthMode get mode => _mode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;
  bool get isStaff => _mode == AuthMode.staff;
  bool get isAdmin => _mode == AuthMode.admin;
  bool get isUser => _mode == AuthMode.user;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final modeStr = prefs.getString('auth_mode');
    if (modeStr == 'user') _mode = AuthMode.user;
    if (modeStr == 'staff') _mode = AuthMode.staff;
    if (modeStr == 'admin') _mode = AuthMode.admin;
    notifyListeners();
  }

  /// POST /api/login  (community user)
  Future<bool> loginUser(String email, String password) async {
    return _doLogin(email, password, AuthMode.user);
  }

  /// POST /api/staff/login
  Future<bool> loginStaff(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.staffLogin(email, password);
      _token = data['token'];
      _staff = Staff.fromJson(data['staff']);
      _mode = AuthMode.staff;
      await _save('staff');
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// POST /api/login  (admin — same endpoint, different role in app)
  Future<bool> loginAdmin(String email, String password) async {
    return _doLogin(email, password, AuthMode.admin);
  }

  /// POST /api/logout
  Future<void> logout() async {
    if (_token != null) {
      try {
        await ApiService.logout(_token!);
      } catch (_) {}
    }
    _token = null;
    _user = null;
    _staff = null;
    _mode = AuthMode.none;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── private ──────────────────────────────────────────────────────────────

  Future<bool> _doLogin(
      String email, String password, AuthMode mode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.login(email, password);
      _token = data['token'];
      _user = User.fromJson(data['user']);
      _mode = mode;
      await _save(mode.name);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _save(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString('token', _token!);
    await prefs.setString('auth_mode', mode);
  }
}
