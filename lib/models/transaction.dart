/// Transaction Item Model
class TransactionItem {
  final String? id;
  final String productId;
  final String productName;
  final String productType;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  TransactionItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.productType,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id']?.toString(),
      productId: json['product_id'].toString(),
      productName: json['product_name'] ?? '',
      productType: json['product_type'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_type': productType,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }
}

/// Transaction Model
class Transaction {
  final String id;
  final String cashierId;
  final String? cashierName;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final List<TransactionItem> items;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.cashierId,
    this.cashierName,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.items,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      cashierId: json['cashier_id'].toString(),
      cashierName: json['cashier_name'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? 'cash',
      status: json['status'] ?? 'completed',
      items:
          (json['items'] as List?)
              ?.map((item) => TransactionItem.fromJson(item))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cashier_id': cashierId,
      'cashier_name': cashierName,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isCompleted => status == 'completed';
  bool get isVoid => status == 'void';
}
