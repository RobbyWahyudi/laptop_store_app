/// Product Model (Base class for Laptop and Accessory)
class Product {
  final String id;
  final String name;
  final String? description;
  final String type; // 'laptop' or 'accessory'
  final double price;
  final int stock;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.price,
    required this.stock,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      type: json['type'] ?? 'laptop',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'price': price,
      'stock': stock,
      'category': category,
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
  final double screenSize;
  final String? screenResolution;
  final String? refreshRate;
  final double? weight;
  final String? operatingSystem;

  Laptop({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    required super.stock,
    super.category,
    required super.createdAt,
    required super.updatedAt,
    required this.brand,
    required this.processor,
    required this.ramGb,
    required this.storage,
    this.gpu,
    required this.screenSize,
    this.screenResolution,
    this.refreshRate,
    this.weight,
    this.operatingSystem,
  }) : super(type: 'laptop');

  factory Laptop.fromJson(Map<String, dynamic> json) {
    return Laptop(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      category: json['category_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      brand: json['brand'] ?? '',
      processor: json['processor'] ?? '',
      ramGb: json['ram_gb'] ?? 0,
      storage: json['storage'] ?? '',
      gpu: json['gpu'],
      screenSize: (json['screen_size'] ?? 0).toDouble(),
      screenResolution: json['screen_resolution'],
      refreshRate: json['refresh_rate'],
      weight: json['weight'] != null ? (json['weight']).toDouble() : null,
      operatingSystem: json['operating_system'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'brand': brand,
      'processor': processor,
      'ram_gb': ramGb,
      'storage': storage,
      'gpu': gpu,
      'screen_size': screenSize,
      'screen_resolution': screenResolution,
      'refresh_rate': refreshRate,
      'weight': weight,
      'operating_system': operatingSystem,
    });
    return json;
  }

  String get specs =>
      '$processor • ${ramGb}GB RAM • $storage${gpu != null ? " • $gpu" : ""}';
}

/// Accessory Model
class Accessory extends Product {
  final String accessoryType;

  Accessory({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    required super.stock,
    super.category,
    required super.createdAt,
    required super.updatedAt,
    required this.accessoryType,
  }) : super(type: 'accessory');

  factory Accessory.fromJson(Map<String, dynamic> json) {
    return Accessory(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      accessoryType: json['accessory_type'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['accessory_type'] = accessoryType;
    return json;
  }
}
