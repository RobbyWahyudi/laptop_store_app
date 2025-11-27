import '../config/api_config.dart';
import '../models/analytics.dart';
import 'api_service.dart';

/// Analytics Service
class AnalyticsService {
  final String token;
  late final ApiService _apiService;

  AnalyticsService(this.token) {
    _apiService = ApiService(token: token);
  }

  /// Get dashboard stats
  Future<DashboardStats> getDashboardStats() async {
    final response = await _apiService.get(ApiConfig.dashboard);

    if (response['success'] == true && response['data'] != null) {
      return DashboardStats.fromJson(response['data']);
    }
    throw Exception('Failed to load dashboard stats');
  }

  /// Get sales summary
  Future<SalesSummary> getSalesSummary({String period = 'daily'}) async {
    final response = await _apiService.get(
      ApiConfig.salesSummary,
      queryParams: {'period': period},
    );

    if (response['success'] == true && response['data'] != null) {
      return SalesSummary.fromJson(response['data']);
    }
    throw Exception('Failed to load sales summary');
  }

  /// Get best sellers
  Future<List<BestSeller>> getBestSellers({int limit = 10}) async {
    final response = await _apiService.get(
      ApiConfig.bestSellers,
      queryParams: {'limit': limit.toString()},
    );

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => BestSeller.fromJson(json)).toList();
    }
    return [];
  }

  /// Get revenue data
  Future<Map<String, dynamic>> getRevenue({String period = 'monthly'}) async {
    final response = await _apiService.get(
      ApiConfig.revenue,
      queryParams: {'period': period},
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'];
    }
    throw Exception('Failed to load revenue data');
  }

  /// Get cashier performance
  Future<List<CashierPerformance>> getCashierPerformance({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final response = await _apiService.get(
      ApiConfig.cashierPerformance,
      queryParams: queryParams,
    );

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => CashierPerformance.fromJson(json)).toList();
    }
    return [];
  }

  /// Get stock alerts
  Future<List<dynamic>> getStockAlerts() async {
    final response = await _apiService.get(ApiConfig.stockAlert);

    if (response['success'] == true && response['data'] != null) {
      return response['data'];
    }
    return [];
  }
}
