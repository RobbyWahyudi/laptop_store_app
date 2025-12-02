// Analytics Models
// Updated to match the actual API response structure

class DashboardStats {
  final TodayStats today;
  final ThisMonthStats thisMonth;
  final List<TopProduct> topProducts;
  final LowStock lowStock;
  final ProductCount productCount;

  DashboardStats({
    required this.today,
    required this.thisMonth,
    required this.topProducts,
    required this.lowStock,
    required this.productCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return DashboardStats(
      today: TodayStats.fromJson(data['today'] as Map<String, dynamic>? ?? {}),
      thisMonth: ThisMonthStats.fromJson(
        data['this_month'] as Map<String, dynamic>? ?? {},
      ),
      topProducts: (data['top_products'] as List? ?? [])
          .map((item) => TopProduct.fromJson(item as Map<String, dynamic>))
          .toList(),
      lowStock: LowStock.fromJson(
        data['low_stock'] as Map<String, dynamic>? ?? {},
      ),
      productCount: ProductCount.fromJson(
        data['product_count'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Today Stats Model
class TodayStats {
  final String period;
  final double totalSales;
  final int totalTransactions;
  final double averageTransaction;
  final PaymentBreakdown paymentBreakdown;
  final String startDate;
  final String endDate;

  TodayStats({
    required this.period,
    required this.totalSales,
    required this.totalTransactions,
    required this.averageTransaction,
    required this.paymentBreakdown,
    required this.startDate,
    required this.endDate,
  });

  factory TodayStats.fromJson(Map<String, dynamic> json) {
    return TodayStats(
      period: json['period'] ?? '',
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
      averageTransaction: (json['average_transaction'] ?? 0).toDouble(),
      paymentBreakdown: PaymentBreakdown.fromJson(
        json['payment_breakdown'] as Map<String, dynamic>? ?? {},
      ),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }
}

/// This Month Stats Model
class ThisMonthStats {
  final String period;
  final double totalSales;
  final int totalTransactions;
  final double averageTransaction;
  final PaymentBreakdown paymentBreakdown;
  final String startDate;
  final String endDate;

  ThisMonthStats({
    required this.period,
    required this.totalSales,
    required this.totalTransactions,
    required this.averageTransaction,
    required this.paymentBreakdown,
    required this.startDate,
    required this.endDate,
  });

  factory ThisMonthStats.fromJson(Map<String, dynamic> json) {
    return ThisMonthStats(
      period: json['period'] ?? '',
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
      averageTransaction: (json['average_transaction'] ?? 0).toDouble(),
      paymentBreakdown: PaymentBreakdown.fromJson(
        json['payment_breakdown'] as Map<String, dynamic>? ?? {},
      ),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }
}

/// Payment Breakdown Model
class PaymentBreakdown {
  final int cash;
  final int qris;
  final int transfer;

  PaymentBreakdown({
    required this.cash,
    required this.qris,
    required this.transfer,
  });

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdown(
      cash: json['cash'] ?? 0,
      qris: json['qris'] ?? 0,
      transfer: json['transfer'] ?? 0,
    );
  }
}

/// Top Product Model
class TopProduct {
  final String productType;
  final int productId;
  final int totalQty;
  final double totalRevenue;
  final int transactionCount;
  final ProductDetails details;

  TopProduct({
    required this.productType,
    required this.productId,
    required this.totalQty,
    required this.totalRevenue,
    required this.transactionCount,
    required this.details,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productType: json['product_type'] ?? '',
      productId: json['product_id'] ?? 0,
      totalQty: json['total_qty'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      transactionCount: json['transaction_count'] ?? 0,
      details: ProductDetails.fromJson(
        json['details'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Product Details Model
class ProductDetails {
  final String name;
  final String brand;
  final double price;

  ProductDetails({
    required this.name,
    required this.brand,
    required this.price,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

/// Low Stock Model
class LowStock {
  final List<LowStockItem> laptops;
  final List<LowStockItem> accessories;
  final int totalAlerts;

  LowStock({
    required this.laptops,
    required this.accessories,
    required this.totalAlerts,
  });

  factory LowStock.fromJson(Map<String, dynamic> json) {
    return LowStock(
      laptops: (json['laptops'] as List? ?? [])
          .map((item) => LowStockItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      accessories: (json['accessories'] as List? ?? [])
          .map((item) => LowStockItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAlerts: json['total_alerts'] ?? 0,
    );
  }
}

/// Low Stock Item Model
class LowStockItem {
  final int id;
  final String name;
  final String brand;
  final String category;
  final int stock;
  final double price;

  LowStockItem({
    required this.id,
    required this.name,
    required this.brand,
    this.category = '',
    required this.stock,
    required this.price,
  });

  factory LowStockItem.fromJson(Map<String, dynamic> json) {
    return LowStockItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

/// Product Count Model
class ProductCount {
  final int laptops;
  final int accessories;
  final int total;

  ProductCount({
    required this.laptops,
    required this.accessories,
    required this.total,
  });

  factory ProductCount.fromJson(Map<String, dynamic> json) {
    return ProductCount(
      laptops: json['laptops'] ?? 0,
      accessories: json['accessories'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

/// Sales Summary Model
class SalesSummary {
  final String period;
  final double totalSales;
  final int totalTransactions;
  final double averageTransaction;
  final List<SalesData> chartData;

  SalesSummary({
    required this.period,
    required this.totalSales,
    required this.totalTransactions,
    required this.averageTransaction,
    required this.chartData,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      period: json['period'] ?? 'daily',
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
      averageTransaction: (json['average_transaction'] ?? 0).toDouble(),
      chartData:
          (json['chart_data'] as List?)
              ?.map((item) => SalesData.fromJson(item))
              .toList() ??
          [],
    );
  }
}

/// Sales Data for Charts
class SalesData {
  final String date;
  final double amount;
  final int transactions;

  SalesData({
    required this.date,
    required this.amount,
    required this.transactions,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      date: json['date'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      transactions: json['transactions'] ?? 0,
    );
  }
}

/// Best Seller Model
class BestSeller {
  final String productId;
  final String productName;
  final String productType;
  final int totalSold;
  final double totalRevenue;

  BestSeller({
    required this.productId,
    required this.productName,
    required this.productType,
    required this.totalSold,
    required this.totalRevenue,
  });

  factory BestSeller.fromJson(Map<String, dynamic> json) {
    return BestSeller(
      productId: json['product_id'].toString(),
      productName: json['product_name'] ?? '',
      productType: json['product_type'] ?? '',
      totalSold: json['total_sold'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }
}

/// Cashier Performance Model
class CashierPerformance {
  final String cashierId;
  final String cashierName;
  final int totalTransactions;
  final double totalSales;
  final double averageTransactionValue;

  CashierPerformance({
    required this.cashierId,
    required this.cashierName,
    required this.totalTransactions,
    required this.totalSales,
    required this.averageTransactionValue,
  });

  factory CashierPerformance.fromJson(Map<String, dynamic> json) {
    return CashierPerformance(
      cashierId: json['cashier_id'].toString(),
      cashierName: json['cashier_name'] ?? '',
      totalTransactions: json['total_transactions'] ?? 0,
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      averageTransactionValue: (json['average_transaction_value'] ?? 0)
          .toDouble(),
    );
  }
}
