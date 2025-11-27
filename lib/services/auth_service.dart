import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../config/constants.dart';
import '../models/user.dart';
import 'api_service.dart';

/// Authentication Service
class AuthService {
  final ApiService _apiService = ApiService();

  /// Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.post(
      ApiConfig.login,
      body: {'email': email, 'password': password},
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];

      // Extract token from response
      final token = data['token'];

      // Create user object from the flat response structure
      final userJson = {
        'id': data['id'],
        'username': data['email'], // Use email as username
        'full_name': data['name'],
        'email': data['email'],
        'role': data['role'],
        'created_at': data['created_at'] ?? DateTime.now().toIso8601String(),
      };

      final user = User.fromJson(userJson);

      // Save token and user data
      await saveAuthData(token, user);

      return {'token': token, 'user': userJson};
    } else {
      throw Exception(response['message'] ?? 'Login failed');
    }
  }

  /// Register
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String fullName,
    required String email,
    required String role,
  }) async {
    final response = await _apiService.post(
      ApiConfig.register,
      body: {
        'username': username,
        'password': password,
        'full_name': fullName,
        'email': email,
        'role': role,
      },
    );

    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? 'Registration failed');
    }
  }

  /// Get Current User
  Future<User> getCurrentUser(String token) async {
    final apiService = ApiService(token: token);
    final response = await apiService.get(ApiConfig.me);

    if (response['success'] == true && response['data'] != null) {
      return User.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Failed to get user data');
    }
  }

  /// Logout
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        final apiService = ApiService(token: token);
        await apiService.post(ApiConfig.logout);
      } catch (e) {
        // Continue logout even if API call fails
      }
    }
    await clearAuthData();
  }

  /// Save auth data to local storage
  Future<void> saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  /// Get token from local storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  /// Get user from local storage
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  /// Clear auth data from local storage
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
