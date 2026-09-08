/// Global application constants for Finclub Loan & Interest Calculator
class AppConstants {
  AppConstants._();

  // App Identity
  static const String appName = 'Finclub';
  static const String appTagline = 'เครื่องมือคำนวณและวางแผนสินเชื่อที่ออกแบบมาเพื่อคุณ';
  static const String appDescription =
      'เครื่องมือคำนวณและจำลองภาระดอกเบี้ยสินเชื่อเบื้องต้น วงเงินสูงสุด 50,000 บาท อัตราดอกเบี้ยสูงสุด 35.80% ต่อปี ไม่ใช่บริการกู้ยืมเงินจริง';

  // Currency & Formatting
  static const String currencySymbol = '฿';
  static const String currencyCode = 'THB';
  static const String locale = 'th_TH';

  // Loan Product Specifications
  static const double maxLoanAmount = 50000.0;
  static const double minLoanAmount = 1000.0;
  static const double defaultLoanAmount = 20000.0;
  static const double loanAmountStep = 1000.0;

  static const double maxInterestRate = 35.80; // 35.80% per annum max
  static const double minInterestRate = 12.00;
  static const double defaultInterestRate = 35.80;

  // Fixed 7 Days Tenure
  static const int fixedTenureDays = 7;
  static const int minTenureMonths = 3;
  static const int maxTenureMonths = 6;
  static const int defaultTenureMonths = 6;
  static const List<int> availableTenures = [3, 4, 5, 6];

  // Quick Amount Presets
  static const List<double> loanAmountPresets = [
    5000.0,
    10000.0,
    20000.0,
    30000.0,
    50000.0,
  ];

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String savedLoansKey = 'saved_loans_list';
  static const String themeKey = 'app_theme';
}
