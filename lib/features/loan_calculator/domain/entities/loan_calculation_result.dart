import 'installment_item.dart';

/// Calculation result model containing all summary metrics and detailed repayment schedule
class LoanCalculationResult {
  final double loanAmount;
  final double annualInterestRate;
  final int tenureMonths;
  final bool isReducingBalance;
  final double monthlyPayment;
  final double totalInterest;
  final double totalPayment;
  final List<InstallmentItem> schedule;

  const LoanCalculationResult({
    required this.loanAmount,
    required this.annualInterestRate,
    required this.tenureMonths,
    required this.isReducingBalance,
    required this.monthlyPayment,
    required this.totalInterest,
    required this.totalPayment,
    required this.schedule,
  });

  /// Percentage of loan amount relative to total repayment
  double get principalRatio => totalPayment > 0 ? (loanAmount / totalPayment) : 1.0;

  /// Percentage of interest relative to total repayment
  double get interestRatio => totalPayment > 0 ? (totalInterest / totalPayment) : 0.0;

  /// Average interest cost per month
  double get averageMonthlyInterest => tenureMonths > 0 ? (totalInterest / tenureMonths) : 0.0;
}
