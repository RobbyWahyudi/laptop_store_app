import '../config/api_config.dart';
import '../models/product.dart';
import 'api_service.dart';

/// AI Recommendation Service
class AIService {
  final String token;
  late final ApiService _apiService;

  AIService(this.token) {
    _apiService = ApiService(token: token);
  }

  /// Get laptop recommendations based on user needs
  Future<List<Laptop>> recommendLaptop({
    required String useCase,
    double? minBudget,
    double? maxBudget,
    int? minRam,
    String? preferredBrand,
    int limit = 5,
  }) async {
    final body = <String, dynamic>{'use_case': useCase, 'limit': limit};

    if (minBudget != null) body['min_budget'] = minBudget;
    if (maxBudget != null) body['max_budget'] = maxBudget;
    if (minRam != null) body['min_ram'] = minRam;
    if (preferredBrand != null) body['preferred_brand'] = preferredBrand;

    final response = await _apiService.post(
      ApiConfig.recommendLaptop,
      body: body,
    );

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Laptop.fromJson(json)).toList();
    }
    return [];
  }

  /// Get accessory recommendations
  Future<List<Accessory>> recommendAccessories({
    String? laptopId,
    int limit = 5,
  }) async {
    final queryParams = <String, String>{'limit': limit.toString()};
    if (laptopId != null) queryParams['laptop_id'] = laptopId;

    final response = await _apiService.get(
      ApiConfig.recommendAccessories,
      queryParams: queryParams,
    );

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Accessory.fromJson(json)).toList();
    }
    return [];
  }
}
