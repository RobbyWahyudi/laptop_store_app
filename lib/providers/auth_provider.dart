import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// Authentication Provider for State Management
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  /// Initialize auth state from storage
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _token = await _authService.getToken();
      _user = await _authService.getUser();

      // Verify token is still valid
      if (_token != null) {
        try {
          _user = await _authService.getCurrentUser(_token!);
        } catch (e) {
          // Token invalid, clear auth
          await _authService.clearAuthData();
          _token = null;
          _user = null;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _authService.login(email, password);
      _token = data['token'];
      _user = User.fromJson(data['user']);
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register
  Future<bool> register({
    required String username,
    required String password,
    required String fullName,
    required String email,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        username: username,
        password: password,
        fullName: fullName,
        email: email,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _user = null;
    _token = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Check user role
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isKasir => _user?.isKasir ?? false;
  bool get isOwner => _user?.isOwner ?? false;
}
