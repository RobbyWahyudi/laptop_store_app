import '../config/api_config.dart';
import '../models/product.dart';
import 'api_service.dart';

/// Product Service
class ProductService {
  final String token;
  late final ApiService _apiService;

  ProductService(this.token) {
    _apiService = ApiService(token: token);
  }

  /// Get all products
  Future<List<Product>> getProducts({
    String? type,
    String? search,
    String? category,
  }) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;
    if (search != null) queryParams['search'] = search;
    if (category != null) queryParams['category'] = category;

    final response = await _apiService.get(
      ApiConfig.products,
      queryParams: queryParams,
    );

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) {
        if (json['type'] == 'laptop') {
          return Laptop.fromJson(json);
        } else {
          return Accessory.fromJson(json);
        }
      }).toList();
    }
    return [];
  }

  /// Get laptops only
  Future<List<Laptop>> getLaptops({String? search, String? category}) async {
    final products = await getProducts(
      type: 'laptop',
      search: search,
      category: category,
    );
    return products.whereType<Laptop>().toList();
  }

  /// Get accessories only
  Future<List<Accessory>> getAccessories({
    String? search,
    String? category,
  }) async {
    final products = await getProducts(
      type: 'accessory',
      search: search,
      category: category,
    );
    return products.whereType<Accessory>().toList();
  }

  /// Get product by ID
  Future<Product> getProductById(String id) async {
    final response = await _apiService.get(ApiConfig.productById(id));

    if (response['success'] == true && response['data'] != null) {
      final json = response['data'];
      if (json['type'] == 'laptop') {
        return Laptop.fromJson(json);
      } else {
        return Accessory.fromJson(json);
      }
    }
    throw Exception('Product not found');
  }

  /// Get low stock products
  Future<List<Product>> getLowStockProducts() async {
    final response = await _apiService.get(ApiConfig.lowStock);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) {
        if (json['type'] == 'laptop') {
          return Laptop.fromJson(json);
        } else {
          return Accessory.fromJson(json);
        }
      }).toList();
    }
    return [];
  }

  /// Create product
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    final response = await _apiService.post(
      ApiConfig.products,
      body: productData,
    );

    if (response['success'] == true && response['data'] != null) {
      final json = response['data'];
      if (json['type'] == 'laptop') {
        return Laptop.fromJson(json);
      } else {
        return Accessory.fromJson(json);
      }
    }
    throw Exception(response['message'] ?? 'Failed to create product');
  }

  /// Update product
  Future<Product> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    final response = await _apiService.put(
      ApiConfig.productById(id),
      body: productData,
    );

    if (response['success'] == true && response['data'] != null) {
      final json = response['data'];
      if (json['type'] == 'laptop') {
        return Laptop.fromJson(json);
      } else {
        return Accessory.fromJson(json);
      }
    }
    throw Exception(response['message'] ?? 'Failed to update product');
  }

  /// Delete product
  Future<void> deleteProduct(String id) async {
    final response = await _apiService.delete(ApiConfig.productById(id));

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to delete product');
    }
  }
}
