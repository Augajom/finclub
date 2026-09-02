import 'package:flutter_test/flutter_test.dart';
import 'package:fintech/features/loan_calculator/domain/usecases/calculate_loan.dart';
import 'package:fintech/core/constants/app_constants.dart';

void main() {
  group('CalculateLoanUseCase Tests', () {
    const calculator = CalculateLoanUseCase();

    test('Calculates 50,000 THB loan at 35.80% p.a. for 6 months (Reducing balance)', () {
      final result = calculator.execute(
        loanAmount: 50000.0,
        annualInterestRate: 35.80,
        tenureMonths: 6,
        isReducingBalance: true,
      );

      expect(result.loanAmount, 50000.0);
      expect(result.annualInterestRate, 35.80);
      expect(result.tenureMonths, 6);
      expect(result.isReducingBalance, isTrue);
      expect(result.schedule.length, 6);

      // Verify schedule integrity: sum of principal must equal total loan amount
      final double totalPrincipalInSchedule =
          result.schedule.fold(0.0, (sum, item) => sum + item.principal);
      expect((totalPrincipalInSchedule - 50000.0).abs(), lessThan(0.05));

      // Verify schedule integrity: sum of interest must equal total interest
      final double totalInterestInSchedule =
          result.schedule.fold(0.0, (sum, item) => sum + item.interest);
      expect((totalInterestInSchedule - result.totalInterest).abs(), lessThan(0.05));

      // Verify last remaining balance is 0.0
      expect(result.schedule.last.remainingBalance, 0.0);

      // Verify monthly payment is in expected range (~9,230 THB)
      expect(result.monthlyPayment, greaterThan(9000.0));
      expect(result.monthlyPayment, lessThan(9500.0));
    });

    test('Calculates 50,000 THB loan for all available tenures (3, 4, 5, 6 months)', () {
      for (final tenure in AppConstants.availableTenures) {
        final result = calculator.execute(
          loanAmount: 50000.0,
          annualInterestRate: 35.80,
          tenureMonths: tenure,
          isReducingBalance: true,
        );

        expect(result.tenureMonths, tenure);
        expect(result.schedule.length, tenure);
        expect(result.schedule.last.remainingBalance, 0.0);
        expect(result.totalPayment, greaterThan(50000.0));
        expect(result.totalInterest, greaterThan(0.0));
      }
    });

    test('Shorter tenure (3 months) has lower total interest than longer tenure (6 months)', () {
      final res3 = calculator.execute(
        loanAmount: 50000.0,
        annualInterestRate: 35.80,
        tenureMonths: 3,
        isReducingBalance: true,
      );

      final res6 = calculator.execute(
        loanAmount: 50000.0,
        annualInterestRate: 35.80,
        tenureMonths: 6,
        isReducingBalance: true,
      );

      expect(res3.totalInterest, lessThan(res6.totalInterest));
      expect(res3.monthlyPayment, greaterThan(res6.monthlyPayment));
    });

    test('Calculates Flat Rate mode correctly', () {
      final result = calculator.execute(
        loanAmount: 50000.0,
        annualInterestRate: 35.80,
        tenureMonths: 6,
        isReducingBalance: false,
      );

      // Flat rate formula: 50000 * 0.358 * (6/12) = 8950.0
      expect((result.totalInterest - 8950.0).abs(), lessThan(0.1));
      expect((result.totalPayment - 58950.0).abs(), lessThan(0.1));
      expect(result.schedule.length, 6);
    });

    test('Handles edge cases (min loan 1,000 and max loan 50,000)', () {
      final minRes = calculator.execute(
        loanAmount: 1000.0,
        annualInterestRate: 35.80,
        tenureMonths: 3,
      );
      expect(minRes.loanAmount, 1000.0);
      expect(minRes.schedule.length, 3);
      expect(minRes.monthlyPayment, greaterThan(0.0));

      final maxRes = calculator.execute(
        loanAmount: 50000.0,
        annualInterestRate: 35.80,
        tenureMonths: 6,
      );
      expect(maxRes.loanAmount, 50000.0);
      expect(maxRes.schedule.length, 6);
    });
  });
}
