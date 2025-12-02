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
    String? brand,
    double? minPrice,
    double? maxPrice,
    int? minRam,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    // Only add type parameter if it's not 'all'
    if (type != null && type != 'all') queryParams['type'] = type;
    if (search != null) queryParams['search'] = search;
    if (category != null) queryParams['category'] = category;
    if (brand != null) queryParams['brand'] = brand;
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (minRam != null) queryParams['min_ram'] = minRam.toString();
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    print('Making API call with params: $queryParams');
    final response = await _apiService.get(
      ApiConfig.products,
      queryParams: queryParams,
    );
    print('API Response: $response');

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      print('Found ${data.length} products in response');
      final products = data.map((json) {
        print('Processing product: $json');
        // Check if this is a laptop by looking for laptop-specific fields
        if (json['cpu'] != null || json['laptop_categories'] != null) {
          print('Creating Laptop');
          return Laptop.fromJson(json);
        } else {
          print('Creating Accessory');
          return Accessory.fromJson(json);
        }
      }).toList();
      print('Created ${products.length} products');
      return products;
    }
    print('No products found or API error');
    return [];
  }

  /// Get laptops only
  Future<List<Laptop>> getLaptops({
    String? search,
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    int? minRam,
    int? page,
    int? limit,
  }) async {
    final products = await getProducts(
      type: 'laptop',
      search: search,
      category: category,
      brand: brand,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRam: minRam,
      page: page,
      limit: limit,
    );
    return products.whereType<Laptop>().toList();
  }

  /// Get accessories only
  Future<List<Accessory>> getAccessories({
    String? search,
    String? category,
    int? page,
    int? limit,
  }) async {
    final products = await getProducts(
      type: 'accessory',
      search: search,
      category: category,
      page: page,
      limit: limit,
    );
    return products.whereType<Accessory>().toList();
  }

  /// Get product by ID
  Future<Product> getProductById(String id) async {
    final response = await _apiService.get(ApiConfig.productById(id));

    if (response['success'] == true && response['data'] != null) {
      final json = response['data'];
      // Check if this is a laptop by looking for laptop-specific fields
      if (json['cpu'] != null || json['laptop_categories'] != null) {
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
        // Check if this is a laptop by looking for laptop-specific fields
        if (json['cpu'] != null || json['laptop_categories'] != null) {
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
      // Check if this is a laptop by looking for laptop-specific fields
      if (json['cpu'] != null || json['laptop_categories'] != null) {
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
      // Check if this is a laptop by looking for laptop-specific fields
      if (json['cpu'] != null || json['laptop_categories'] != null) {
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
