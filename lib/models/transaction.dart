/// Transaction Item Model
class TransactionItem {
  final String? id;
  final String productId;
  final String productType;
  final int quantity;
  final double price;
  final String? transactionId;
  final Map<String, dynamic>? productDetails;

  TransactionItem({
    this.id,
    required this.productId,
    required this.productType,
    required this.quantity,
    required this.price,
    this.transactionId,
    this.productDetails,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id']?.toString(),
      productId: json['product_id'].toString(),
      productType: json['product_type'] ?? '',
      quantity: json['qty'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      transactionId: json['transaction_id']?.toString(),
      productDetails: json['product_details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'product_type': productType,
      'qty': quantity,
      'price': price,
      if (transactionId != null) 'transaction_id': transactionId,
      if (productDetails != null) 'product_details': productDetails,
    };
  }

  String get productName => productDetails?['name'] ?? 'Unknown Product';
  double get subtotal => price * quantity;
}

/// Transaction Model
class Transaction {
  final String id;
  final String cashierId;
  final String customerName;
  final double totalPrice;
  final String paymentMethod;
  final DateTime createdAt;
  final Map<String, dynamic>? user;
  final List<TransactionItem> transactionItems;

  Transaction({
    required this.id,
    required this.cashierId,
    required this.customerName,
    required this.totalPrice,
    required this.paymentMethod,
    required this.createdAt,
    this.user,
    required this.transactionItems,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      cashierId: json['cashier_id'].toString(),
      customerName: json['customer_name'] ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? 'cash',
      createdAt: DateTime.parse(json['created_at']),
      user: json['users'] as Map<String, dynamic>?,
      transactionItems:
          (json['transaction_items'] as List?)
              ?.map((item) => TransactionItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cashier_id': cashierId,
      'customer_name': customerName,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      if (user != null) 'users': user,
      'transaction_items': transactionItems
          .map((item) => item.toJson())
          .toList(),
    };
  }

  String get cashierName => user?['name'] ?? 'Unknown';
  int get totalItems =>
      transactionItems.fold(0, (sum, item) => sum + item.quantity);
  bool get isCompleted =>
      true; // Assuming all are completed since no status in API
}
