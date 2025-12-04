/// Product Model (Base class for Laptop and Accessory)
class Product {
  final String id;
  final String name;
  final String type; // 'laptop' or 'accessory'
  final double price;
  final int stock;
  final String? category;
  final int? categoryId; // Add category ID
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.stock,
    this.category,
    this.categoryId, // Add categoryId parameter
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? 'laptop',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      category: json['category'],
      categoryId: json['category_id'], // Add categoryId
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'price': price,
      'stock': stock,
      'category': category,
      'category_id': categoryId, // Add categoryId
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isLowStock => stock < 5;
  bool get isOutOfStock => stock == 0;
  bool get isLaptop => type == 'laptop';
  bool get isAccessory => type == 'accessory';
}

/// Laptop Model with detailed specifications
class Laptop extends Product {
  final String brand;
  final String processor;
  final int ramGb;
  final String storage;
  final String? gpu;
  final String? screenResolution;
  final double? weight;
  final String? operatingSystem;

  Laptop({
    required super.id,
    required super.name,
    required super.price,
    required super.stock,
    super.category,
    super.categoryId, // Add categoryId parameter
    required super.createdAt,
    required super.updatedAt,
    required this.brand,
    required this.processor,
    required this.ramGb,
    required this.storage,
    this.gpu,
    this.screenResolution,
    this.weight,
    this.operatingSystem,
  }) : super(type: 'laptop');

  factory Laptop.fromJson(Map<String, dynamic> json) {
    // Extract category ID from different possible sources
    int? categoryId;
    if (json['laptop_categories'] != null && json['laptop_categories'] is Map) {
      categoryId = json['laptop_categories']['id'];
    } else if (json['category_id'] != null) {
      categoryId = json['category_id'];
    }

    // Extract category name from different possible sources
    String? categoryName;
    if (json['laptop_categories'] != null && json['laptop_categories'] is Map) {
      categoryName = json['laptop_categories']['name'];
    } else if (json['category_name'] != null) {
      categoryName = json['category_name'];
    }

    return Laptop(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      category: categoryName,
      categoryId: categoryId,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      brand: json['brand'] ?? '',
      processor: json['cpu'] ?? '',
      ramGb: json['ram'] ?? 0,
      storage: json['storage'] ?? '',
      gpu: json['gpu'],
      screenResolution: json['display'],
      weight: json['weight'] != null ? (json['weight']).toDouble() : null,
      operatingSystem: json['os'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'brand': brand,
      'cpu': processor,
      'ram': ramGb,
      'storage': storage,
      'gpu': gpu,
      'display':
          screenResolution, // Using screenResolution as it contains the full display string
      'weight': weight,
      'os': operatingSystem,
    });
    return json;
  }

  String get specs =>
      '$processor • ${ramGb}GB RAM • $storage${gpu != null ? " • $gpu" : ""}';
}

/// Accessory Model
class Accessory extends Product {
  // Removed accessoryType field

  Accessory({
    required super.id,
    required super.name,
    required super.price,
    required super.stock,
    super.category,
    super.categoryId, // Add categoryId parameter
    required super.createdAt,
    required super.updatedAt,
    // Removed accessoryType parameter
  }) : super(type: 'accessory');

  factory Accessory.fromJson(Map<String, dynamic> json) {
    // Extract category ID from different possible sources
    int? categoryId;
    if (json['laptop_categories'] != null && json['laptop_categories'] is Map) {
      categoryId = json['laptop_categories']['id'];
    } else if (json['category_id'] != null) {
      categoryId = json['category_id'];
    }

    // Extract category name from different possible sources
    String? categoryName;
    if (json['category'] != null) {
      categoryName = json['category'];
    } else if (json['laptop_categories'] != null &&
        json['laptop_categories'] is Map) {
      categoryName = json['laptop_categories']['name'];
    }

    return Accessory(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      category: categoryName,
      categoryId: categoryId,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      // Removed accessoryType assignment
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    // Removed accessory_type from json
    return json;
  }
}
