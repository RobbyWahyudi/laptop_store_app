import '../config/api_config.dart';
import '../models/transaction.dart';
import 'api_service.dart';

/// Transaction Service
class TransactionService {
  final String token;
  late final ApiService _apiService;

  TransactionService(this.token) {
    _apiService = ApiService(token: token);
  }

  /// Get all transactions
  Future<List<Transaction>> getTransactions({
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final response = await _apiService.get(
      ApiConfig.transactions,
      queryParams: queryParams,
    );

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Transaction.fromJson(json)).toList();
    }
    return [];
  }

  /// Get today's transactions
  Future<List<Transaction>> getTodayTransactions() async {
    final response = await _apiService.get(ApiConfig.todayTransactions);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Transaction.fromJson(json)).toList();
    }
    return [];
  }

  /// Get transaction by ID
  Future<Transaction> getTransactionById(String id) async {
    final response = await _apiService.get(ApiConfig.transactionById(id));

    if (response['success'] == true && response['data'] != null) {
      return Transaction.fromJson(response['data']);
    }
    throw Exception('Transaction not found');
  }

  /// Create transaction
  Future<Transaction> createTransaction({
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _apiService.post(
      ApiConfig.transactions,
      body: {
        'payment_method': paymentMethod,
        'items': items,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      return Transaction.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to create transaction');
  }

  /// Void transaction
  Future<void> voidTransaction(String id) async {
    final response = await _apiService.delete(ApiConfig.transactionById(id));

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to void transaction');
    }
  }

  /// Get today's stats
  Future<Map<String, dynamic>> getTodayStats() async {
    final transactions = await getTodayTransactions();
    
    final completedTransactions = transactions.where((t) => t.isCompleted).toList();
    final totalSales = completedTransactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.totalAmount,
    );

    return {
      'total_transactions': completedTransactions.length,
      'total_sales': totalSales,
      'transactions': completedTransactions,
    };
  }
}
