/// Represents a saved 7-day loan calculation simulation in user's history
class SavedLoanItem {
  final String id;
  final String title;
  final DateTime createdAt;
  final double loanAmount; // Principal (เงินต้น)
  final double interestPerDay; // ดอกเบี้ยต่อวัน
  final double totalInterest; // ดอกเบี้ยรวม 7 วัน
  final double revenueFee; // ค่าดำเนินการหรือ enue
  final double totalAmount; // ยอด Total รวม
  final int tenureDays; // 7 วัน Fixed
  final String dueDate; // วันครบกำหนด
  final double annualInterestRate;
  final String? note;

  const SavedLoanItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.loanAmount,
    required this.interestPerDay,
    required this.totalInterest,
    required this.revenueFee,
    required this.totalAmount,
    this.tenureDays = 7,
    required this.dueDate,
    this.annualInterestRate = 35.80,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'loanAmount': loanAmount,
      'interestPerDay': interestPerDay,
      'totalInterest': totalInterest,
      'revenueFee': revenueFee,
      'totalAmount': totalAmount,
      'tenureDays': tenureDays,
      'dueDate': dueDate,
      'annualInterestRate': annualInterestRate,
      'note': note,
    };
  }

  factory SavedLoanItem.fromJson(Map<String, dynamic> json) {
    final amount = (json['loanAmount'] as num?)?.toDouble() ?? 20000.0;
    final dailyInterest = (json['interestPerDay'] as num?)?.toDouble() ??
        (((amount * 0.358) / 365 * 100).roundToDouble() / 100.0);
    final totInterest = (json['totalInterest'] as num?)?.toDouble() ?? (dailyInterest * 7);
    final fee = (json['revenueFee'] as num?)?.toDouble() ?? (amount * 0.01 > 50 ? amount * 0.01 : 50.0);
    final total = (json['totalAmount'] as num?)?.toDouble() ?? (amount + totInterest + fee);

    return SavedLoanItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'แผนสินเชื่อ 7 วัน',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      loanAmount: amount,
      interestPerDay: dailyInterest,
      totalInterest: totInterest,
      revenueFee: fee,
      totalAmount: total,
      tenureDays: json['tenureDays'] as int? ?? 7,
      dueDate: json['dueDate'] as String? ?? '7 วันหลังจากอนุมัติ',
      annualInterestRate: (json['annualInterestRate'] as num?)?.toDouble() ?? 35.80,
      note: json['note'] as String?,
    );
  }
}
