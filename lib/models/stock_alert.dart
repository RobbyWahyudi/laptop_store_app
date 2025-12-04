// Stock Alert Models
class StockAlertResponse {
  final bool success;
  final String message;
  final StockAlertData data;

  StockAlertResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StockAlertResponse.fromJson(Map<String, dynamic> json) {
    return StockAlertResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: StockAlertData.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class StockAlertData {
  final List<StockAlertItem> laptops;
  final List<StockAlertItem> accessories;
  final int totalAlerts;

  StockAlertData({
    required this.laptops,
    required this.accessories,
    required this.totalAlerts,
  });

  factory StockAlertData.fromJson(Map<String, dynamic> json) {
    return StockAlertData(
      laptops: (json['laptops'] as List? ?? [])
          .map((item) => StockAlertItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      accessories: (json['accessories'] as List? ?? [])
          .map((item) => StockAlertItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAlerts: json['total_alerts'] ?? 0,
    );
  }
}

class StockAlertItem {
  final int id;
  final String name;
  final String brand;
  final String category;
  final int stock;
  final double price;

  StockAlertItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.stock,
    required this.price,
  });

  factory StockAlertItem.fromJson(Map<String, dynamic> json) {
    return StockAlertItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
