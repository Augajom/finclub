/// Represents an individual installment row in the loan repayment schedule
class InstallmentItem {
  final int period;
  final String dueDate;
  final double paymentAmount;
  final double principal;
  final double interest;
  final double remainingBalance;

  const InstallmentItem({
    required this.period,
    required this.dueDate,
    required this.paymentAmount,
    required this.principal,
    required this.interest,
    required this.remainingBalance,
  });

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'dueDate': dueDate,
      'paymentAmount': paymentAmount,
      'principal': principal,
      'interest': interest,
      'remainingBalance': remainingBalance,
    };
  }

  factory InstallmentItem.fromJson(Map<String, dynamic> json) {
    return InstallmentItem(
      period: json['period'] as int,
      dueDate: json['dueDate'] as String,
      paymentAmount: (json['paymentAmount'] as num).toDouble(),
      principal: (json['principal'] as num).toDouble(),
      interest: (json['interest'] as num).toDouble(),
      remainingBalance: (json['remainingBalance'] as num).toDouble(),
    );
  }
}
