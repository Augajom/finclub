/// Represents 7-day fixed micro loan calculation and result
class SevenDayLoanResult {
  final double principal;
  final int tenureDays;
  final double annualInterestRate;
  final double interestPerDay;
  final double totalInterest;
  final double revenueFee;
  final double totalAmount;
  final String dueDate;
  final DateTime? dueDateTime;

  const SevenDayLoanResult({
    required this.principal,
    this.tenureDays = 7,
    required this.annualInterestRate,
    required this.interestPerDay,
    required this.totalInterest,
    required this.revenueFee,
    required this.totalAmount,
    required this.dueDate,
    this.dueDateTime,
  });

  /// Formats due date according to user language (Thai Buddhist year vs Gregorian CE)
  String getDueDateFormatted({bool isThai = true}) {
    final d = dueDateTime;
    if (d == null) return dueDate;
    if (isThai) {
      const thaiMonths = [
        'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
        'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
      ];
      return '${d.day} ${thaiMonths[d.month - 1]} ${d.year + 543}';
    } else {
      const engMonths = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${d.day} ${engMonths[d.month - 1]} ${d.year}';
    }
  }

  /// Compute locally
  factory SevenDayLoanResult.compute({
    required double principal,
    double annualRate = 35.80,
  }) {
    final clampedPrincipal = principal.clamp(1000.0, 50000.0);

    // Daily interest formula: Principal * (AnnualRate / 100) / 365
    final dailyInterestRaw = (clampedPrincipal * (annualRate / 100.0)) / 365.0;
    final interestPerDay = (dailyInterestRaw * 100).roundToDouble() / 100.0;

    // Total 7-day interest
    final totalInterest = ((interestPerDay * 7) * 100).roundToDouble() / 100.0;

    // Processing / Platform Revenue Fee (ค่าดำเนินการหรือ enue) - 50 THB or 1%
    final feeRaw = clampedPrincipal * 0.01;
    final revenueFee = feeRaw > 50.0 ? ((feeRaw * 100).roundToDouble() / 100.0) : 50.0;

    // Total Repayment (เงินต้น + ดอกเบี้ย 7 วัน + ค่าดำเนินการ)
    final totalAmount = ((clampedPrincipal + totalInterest + revenueFee) * 100).roundToDouble() / 100.0;

    final due = DateTime.now().add(const Duration(days: 7));
    const thaiMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    final formattedDueDate = '${due.day} ${thaiMonths[due.month - 1]} ${due.year + 543}';

    return SevenDayLoanResult(
      principal: clampedPrincipal,
      tenureDays: 7,
      annualInterestRate: annualRate,
      interestPerDay: interestPerDay,
      totalInterest: totalInterest,
      revenueFee: revenueFee,
      totalAmount: totalAmount,
      dueDate: formattedDueDate,
      dueDateTime: due,
    );
  }

  factory SevenDayLoanResult.fromJson(Map<String, dynamic> json) {
    return SevenDayLoanResult(
      principal: (json['principal'] as num).toDouble(),
      tenureDays: json['tenure_days'] as int? ?? 7,
      annualInterestRate: (json['annual_interest_rate'] as num?)?.toDouble() ?? 35.80,
      interestPerDay: (json['interest_per_day'] as num).toDouble(),
      totalInterest: (json['total_interest'] as num).toDouble(),
      revenueFee: (json['revenue_fee'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      dueDate: json['due_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'principal': principal,
      'tenure_days': tenureDays,
      'annual_interest_rate': annualInterestRate,
      'interest_per_day': interestPerDay,
      'total_interest': totalInterest,
      'revenue_fee': revenueFee,
      'total_amount': totalAmount,
      'due_date': dueDate,
    };
  }
}
