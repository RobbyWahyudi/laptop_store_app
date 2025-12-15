import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  ProductService? _productService;

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  void initialize(String token) {
    _productService = ProductService(token);
  }

  Future<void> loadProducts({
    String? type,
    String? search,
    String? category,
  }) async {
    if (_productService == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await _productService!.getProducts(
        type: type ?? 'all',
        search: search,
        category: category,
        limit: 1000, // Request all products (increase limit)
      );
      _products = products;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> createProduct(Map<String, dynamic> productData) async {
    if (_productService == null) return null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final product = await _productService!.createProduct(productData);
      _products.insert(0, product);
      _error = null;
      notifyListeners();
      return product;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    if (_productService == null) return null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final product = await _productService!.updateProduct(id, productData);

      // Update in list
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = product;
      }

      _error = null;
      notifyListeners();
      return product;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String id, String type) async {
    if (_productService == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _productService!.deleteProduct(id, type);

      // Remove from list
      _products.removeWhere((p) => p.id == id);

      _error = null;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
