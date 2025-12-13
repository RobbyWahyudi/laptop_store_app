import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration for LaptopStore+ Backend
class ApiConfig {
  // Auto-detect base URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      // Web: use localhost
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      // Android Emulator: use 10.0.2.2 to access host machine
      // For physical device, replace with your PC's IP (e.g., 'http://192.168.1.100:3000')
      return 'http://192.168.111.120:3000';
    } else {
      // iOS, Windows, macOS, Linux: use localhost
      return 'http://localhost:3000';
    }
  }

  static String get apiUrl => '$baseUrl/api';

  // Authentication Endpoints
  static String get login => '$apiUrl/auth/login';
  static String get register => '$apiUrl/auth/register';
  static String get logout => '$apiUrl/auth/logout';
  static String get me => '$apiUrl/auth/me';

  // Product Endpoints
  static String get products => '$apiUrl/products';
  static String productById(String id) => '$apiUrl/products/$id';
  static String get categories => '$apiUrl/categories';
  static String get lowStock => '$apiUrl/products/low-stock';

  // Transaction Endpoints
  static String get transactions => '$apiUrl/transactions';
  static String transactionById(String id) => '$apiUrl/transactions/$id';
  static String get todayTransactions => '$apiUrl/transactions/today';

  // AI Recommendation Endpoints
  static String get recommendLaptop => '$apiUrl/ai/recommend-laptop';
  static String get recommendAccessories => '$apiUrl/ai/recommend-accessories';

  // Analytics Endpoints
  static String get dashboard => '$apiUrl/analytics/dashboard';
  static String get salesSummary => '$apiUrl/analytics/sales-summary';
  static String get bestSellers => '$apiUrl/analytics/best-sellers';
  static String get revenue => '$apiUrl/analytics/revenue';
  static String get cashierPerformance =>
      '$apiUrl/analytics/cashier-performance';
  static String get stockAlert => '$apiUrl/analytics/stock-alert';

  // Health Check
  static String get health => '$apiUrl/health';

  // Request Headers
  static Map<String, String> headers({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
