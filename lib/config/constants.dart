/// App Constants
class AppConstants {
  // App Info
  static const String appName = 'LaptopStore+';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleKasir = 'kasir';
  static const String roleOwner = 'owner';

  // Product Types
  static const String productTypeLaptop = 'laptop';
  static const String productTypeAccessory = 'accessory';

  // Payment Methods
  static const String paymentCash = 'cash';
  static const String paymentQris = 'qris';
  static const String paymentTransfer = 'transfer';

  // Transaction Status
  static const String statusCompleted = 'completed';
  static const String statusVoid = 'void';

  // Laptop Use Cases (for AI Recommendation)
  static const List<String> useCases = [
    'gaming',
    'editing',
    'programming',
    'office',
    'bisnis',
  ];

  // Pagination
  static const int defaultPageSize = 20;

  // Date Format
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
}
