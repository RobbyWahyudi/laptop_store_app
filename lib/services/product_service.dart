import '../config/api_config.dart';
import '../models/category.dart';
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
    // Always include the type parameter, even if it is 'all'
    // This ensures that when type is 'all', we explicitly send 'type=all' to the backend
    if (type != null) queryParams['type'] = type;
    if (search != null) queryParams['search'] = search;
    if (category != null) queryParams['category'] = category;
    if (brand != null) queryParams['brand'] = brand;
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (minRam != null) queryParams['min_ram'] = minRam.toString();
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await _apiService.get(
      ApiConfig.products,
      queryParams: queryParams,
    );

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      final products = data.map((json) {
        // Check if this is a laptop by looking for laptop-specific fields
        if (json['cpu'] != null || json['laptop_categories'] != null) {
          return Laptop.fromJson(json);
        } else {
          return Accessory.fromJson(json);
        }
      }).toList();
      return products;
    }
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
    try {
      print('Creating product with data: $productData');
      final response = await _apiService.post(
        ApiConfig.products,
        body: productData,
      );
      print('Create product response: $response');

      if (response['success'] == true && response['data'] != null) {
        final json = response['data'];
        print('Created product data: $json');
        // Check if this is a laptop by looking for laptop-specific fields
        if (json['cpu'] != null || json['laptop_categories'] != null) {
          return Laptop.fromJson(json);
        } else {
          return Accessory.fromJson(json);
        }
      }
      throw Exception(response['message'] ?? 'Failed to create product');
    } catch (e) {
      print('Error creating product with data $productData: $e');
      rethrow;
    }
  }

  /// Update product
  Future<Product> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    try {
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
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  /// Delete product
  Future<void> deleteProduct(String id, String type) async {
    try {
      print('Attempting to delete product with ID: $id and type: $type');
      final url = ApiConfig.productById(id);
      print('DELETE URL: $url');

      // Add type parameter to query params
      final queryParams = <String, String>{'type': type};
      print('DELETE Query params: $queryParams');

      final response = await _apiService.delete(url, queryParams: queryParams);
      print('DELETE response: $response');

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete product');
      }
    } catch (e) {
      print('Error deleting product with ID $id and type $type: $e');
      rethrow;
    }
  }

  /// Get all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get(ApiConfig.categories);

      // Handle direct array response (if API returns array directly)
      if (response is List) {
        final List<dynamic> categoriesList = response as List;
        return categoriesList
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // Handle wrapped response (with success/data fields)
      // At this point, response must be a Map if it's not a List
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'] as List;
        return data
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Handle case where response is a map with categories directly
      if (response.containsKey('categories')) {
        final List<dynamic> data = response['categories'] as List;
        return data
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Handle error silently
    }
    return [];
  }
}
