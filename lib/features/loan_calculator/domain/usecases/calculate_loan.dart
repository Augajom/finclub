import 'dart:math' as math;
import '../entities/installment_item.dart';
import '../entities/loan_calculation_result.dart';

/// Business logic use case for accurate loan calculation
class CalculateLoanUseCase {
  const CalculateLoanUseCase();

  LoanCalculationResult execute({
    required double loanAmount,
    required double annualInterestRate,
    required int tenureMonths,
    bool isReducingBalance = true,
    DateTime? startDate,
  }) {
    final effectiveStartDate = startDate ?? DateTime.now();

    if (loanAmount <= 0 || tenureMonths <= 0) {
      return LoanCalculationResult(
        loanAmount: loanAmount,
        annualInterestRate: annualInterestRate,
        tenureMonths: tenureMonths,
        isReducingBalance: isReducingBalance,
        monthlyPayment: 0.0,
        totalInterest: 0.0,
        totalPayment: 0.0,
        schedule: const [],
      );
    }

    if (isReducingBalance) {
      return _calculateReducingBalance(
        loanAmount: loanAmount,
        annualInterestRate: annualInterestRate,
        tenureMonths: tenureMonths,
        startDate: effectiveStartDate,
      );
    } else {
      return _calculateFlatRate(
        loanAmount: loanAmount,
        annualInterestRate: annualInterestRate,
        tenureMonths: tenureMonths,
        startDate: effectiveStartDate,
      );
    }
  }

  /// Calculates loan using Effective Interest Rate (ลดต้นลดดอก)
  LoanCalculationResult _calculateReducingBalance({
    required double loanAmount,
    required double annualInterestRate,
    required int tenureMonths,
    required DateTime startDate,
  }) {
    final double monthlyRate = (annualInterestRate / 100.0) / 12.0;

    double pmt;
    if (monthlyRate == 0) {
      pmt = loanAmount / tenureMonths;
    } else {
      final double compoundFactor = math.pow(1.0 + monthlyRate, tenureMonths).toDouble();
      pmt = loanAmount * (monthlyRate * compoundFactor) / (compoundFactor - 1.0);
    }

    // Round PMT to 2 decimal places standard
    final double roundedPmt = (pmt * 100).roundToDouble() / 100.0;

    final List<InstallmentItem> schedule = [];
    double remainingBalance = loanAmount;
    double sumInterest = 0.0;
    double sumPayment = 0.0;

    for (int i = 1; i <= tenureMonths; i++) {
      final dueDate = _getDueDateString(startDate, i);
      final double interestForPeriod = (remainingBalance * monthlyRate * 100).roundToDouble() / 100.0;

      double principalForPeriod;
      double actualPayment;

      if (i == tenureMonths) {
        // Last month: clear exact remaining balance
        principalForPeriod = remainingBalance;
        actualPayment = principalForPeriod + interestForPeriod;
        remainingBalance = 0.0;
      } else {
        principalForPeriod = roundedPmt - interestForPeriod;
        if (principalForPeriod > remainingBalance) {
          principalForPeriod = remainingBalance;
        }
        actualPayment = roundedPmt;
        remainingBalance = (((remainingBalance - principalForPeriod) * 100).roundToDouble()) / 100.0;
        if (remainingBalance < 0) remainingBalance = 0.0;
      }

      sumInterest += interestForPeriod;
      sumPayment += actualPayment;

      schedule.add(
        InstallmentItem(
          period: i,
          dueDate: dueDate,
          paymentAmount: actualPayment,
          principal: principalForPeriod,
          interest: interestForPeriod,
          remainingBalance: remainingBalance,
        ),
      );
    }

    return LoanCalculationResult(
      loanAmount: loanAmount,
      annualInterestRate: annualInterestRate,
      tenureMonths: tenureMonths,
      isReducingBalance: true,
      monthlyPayment: roundedPmt,
      totalInterest: (sumInterest * 100).roundToDouble() / 100.0,
      totalPayment: (sumPayment * 100).roundToDouble() / 100.0,
      schedule: schedule,
    );
  }

  /// Calculates loan using Flat Rate (ดอกเบี้ยคงที่)
  LoanCalculationResult _calculateFlatRate({
    required double loanAmount,
    required double annualInterestRate,
    required int tenureMonths,
    required DateTime startDate,
  }) {
    final double totalInterestRaw = loanAmount * (annualInterestRate / 100.0) * (tenureMonths / 12.0);
    final double totalInterest = (totalInterestRaw * 100).roundToDouble() / 100.0;
    final double totalPayment = loanAmount + totalInterest;
    final double monthlyPayment = ((totalPayment / tenureMonths) * 100).roundToDouble() / 100.0;

    final double monthlyPrincipal = ((loanAmount / tenureMonths) * 100).roundToDouble() / 100.0;
    final double monthlyInterest = ((totalInterest / tenureMonths) * 100).roundToDouble() / 100.0;

    final List<InstallmentItem> schedule = [];
    double remainingBalance = loanAmount;

    for (int i = 1; i <= tenureMonths; i++) {
      final dueDate = _getDueDateString(startDate, i);
      final double principal = (i == tenureMonths) ? remainingBalance : monthlyPrincipal;
      final double interest = monthlyInterest;
      remainingBalance = (((remainingBalance - principal) * 100).roundToDouble()) / 100.0;
      if (remainingBalance < 0) remainingBalance = 0.0;

      schedule.add(
        InstallmentItem(
          period: i,
          dueDate: dueDate,
          paymentAmount: principal + interest,
          principal: principal,
          interest: interest,
          remainingBalance: remainingBalance,
        ),
      );
    }

    return LoanCalculationResult(
      loanAmount: loanAmount,
      annualInterestRate: annualInterestRate,
      tenureMonths: tenureMonths,
      isReducingBalance: false,
      monthlyPayment: monthlyPayment,
      totalInterest: totalInterest,
      totalPayment: totalPayment,
      schedule: schedule,
    );
  }

  /// Generates human-friendly Thai formatted due date
  String _getDueDateString(DateTime startDate, int monthOffset) {
    final year = startDate.year;
    final month = startDate.month + monthOffset;
    final normalizedYear = year + ((month - 1) ~/ 12);
    final normalizedMonth = ((month - 1) % 12) + 1;
    final day = math.min(startDate.day, _daysInMonth(normalizedYear, normalizedMonth));

    const thaiMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];

    final thaiYear = normalizedYear + 543;
    return '$day ${thaiMonths[normalizedMonth - 1]} $thaiYear';
  }

  int _daysInMonth(int year, int month) {
    if (month == 2) {
      final isLeap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeap ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }
}
