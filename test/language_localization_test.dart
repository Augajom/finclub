import 'package:flutter_test/flutter_test.dart';
import 'package:fintech/core/localization/app_strings.dart';

void main() {
  group('Localization AppStrings Tests', () {
    test('Ensures critical keys exist in both Thai and English', () {
      final criticalKeys = [
        'navCalculator',
        'navSchedule',
        'navSavedPlans',
        'navProductInfo',
        'loan7DaysTitle',
        'principalLabel',
        'dailyInterestLabel',
        'revenueFeeLabel',
        'totalRepaymentLabel',
        'securityTitle',
        'changePin',
        'setPin',
        'biometricTitle',
        'savedLoansTitle',
        'productInfoTitle',
        'confirmApplyTitle',
        'deletePlanModalTitle',
        'perDay',
      ];

      for (final key in criticalKeys) {
        final thVal = AppStrings.get(key, lang: 'th');
        final enVal = AppStrings.get(key, lang: 'en');

        expect(thVal, isNotEmpty, reason: 'Key "$key" should not be empty in Thai');
        expect(enVal, isNotEmpty, reason: 'Key "$key" should not be empty in English');
        expect(thVal, isNot(equals(key)), reason: 'Key "$key" should have translation in Thai');
        expect(enVal, isNot(equals(key)), reason: 'Key "$key" should have translation in English');
      }
    });

    test('Thai and English translations are distinctly different', () {
      expect(AppStrings.get('navCalculator', lang: 'th'), 'คำนวณสินเชื่อ');
      expect(AppStrings.get('navCalculator', lang: 'en'), 'Calculator');

      expect(AppStrings.get('navSchedule', lang: 'th'), 'ตารางผ่อน');
      expect(AppStrings.get('navSchedule', lang: 'en'), 'Schedule');

      expect(AppStrings.get('navSavedPlans', lang: 'th'), 'บันทึก');
      expect(AppStrings.get('navSavedPlans', lang: 'en'), 'Saved Plans');

      expect(AppStrings.get('navProductInfo', lang: 'th'), 'ข้อมูลสินเชื่อ');
      expect(AppStrings.get('navProductInfo', lang: 'en'), 'Loan Info');
    });
  });
}
