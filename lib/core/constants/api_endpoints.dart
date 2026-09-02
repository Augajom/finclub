/// API endpoints and configuration constants
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.example.com/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';

  // Wallet & Accounts
  static const String accounts = '/wallet/accounts';
  static const String balance = '/wallet/balance';
  static const String transactions = '/wallet/transactions';
  static const String transfer = '/wallet/transfer';
}
