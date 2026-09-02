import 'package:flutter_test/flutter_test.dart';
import 'package:fintech/features/loan_calculator/domain/entities/seven_day_loan_result.dart';

void main() {
  group('7-Day Fixed Loan Calculation Tests', () {
    test('Calculates 20,000 THB 7-Day Loan accurately', () {
      final res = SevenDayLoanResult.compute(
        principal: 20000.0,
        annualRate: 35.80,
      );

      expect(res.principal, 20000.0);
      expect(res.tenureDays, 7);
      expect(res.annualInterestRate, 35.80);

      // Daily interest = (20000 * 0.358) / 365 = 19.6164 -> ~19.62
      expect(res.interestPerDay, closeTo(19.62, 0.05));

      // 7 days total interest = 19.62 * 7 = 137.34
      expect(res.totalInterest, closeTo(137.34, 0.2));

      // Revenue / Service fee (58.1% of 20,000 = 11,620.00)
      expect(res.revenueFee, 11620.0);

      // Total repayment = 20000 + 137.34 + 11620.00 = 31757.34
      expect(res.totalAmount, closeTo(31757.34, 0.25));
    });

    test('Calculates 50,000 THB max loan accurately', () {
      final res = SevenDayLoanResult.compute(
        principal: 50000.0,
        annualRate: 35.80,
      );

      expect(res.principal, 50000.0);
      // Daily interest = (50000 * 0.358) / 365 = 49.041 -> ~49.04
      expect(res.interestPerDay, closeTo(49.04, 0.05));
      // Total 7-day interest = 49.04 * 7 = 343.28
      expect(res.totalInterest, closeTo(343.28, 0.2));
      // Revenue fee (58.1% of 50,000 = 29,050.0)
      expect(res.revenueFee, 29050.0);
      // Total amount = 50000 + 343.28 + 29050 = 79393.28
      expect(res.totalAmount, closeTo(79393.28, 0.25));
    });

    test('Calculates 58.1% revenue fee for small loans', () {
      final res = SevenDayLoanResult.compute(
        principal: 1000.0,
        annualRate: 35.80,
      );

      expect(res.principal, 1000.0);
      // 58.1% of 1,000 = 581.00
      expect(res.revenueFee, 581.0);
      expect(res.totalAmount, closeTo(1587.87, 0.25));
    });
  });
}
