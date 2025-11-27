/// Dashboard Stats Model
class DashboardStats {
  final double todaySales;
  final int todayTransactions;
  final int lowStockProducts;
  final double monthlyRevenue;

  DashboardStats({
    required this.todaySales,
    required this.todayTransactions,
    required this.lowStockProducts,
    required this.monthlyRevenue,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      todaySales: (json['today_sales'] ?? 0).toDouble(),
      todayTransactions: json['today_transactions'] ?? 0,
      lowStockProducts: json['low_stock_products'] ?? 0,
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
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
