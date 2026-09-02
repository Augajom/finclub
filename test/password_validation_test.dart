import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Password Rules Validation Tests', () {
    bool hasUppercase(String p) => RegExp(r'[A-Z]').hasMatch(p);
    bool hasLowercase(String p) => RegExp(r'[a-z]').hasMatch(p);
    bool hasNumber(String p) => RegExp(r'[0-9]').hasMatch(p);
    bool hasSpecial(String p) => RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\\/\[\]~`]').hasMatch(p);
    bool hasMinLength(String p) => p.length >= 8;
    bool isValid(String p) =>
        hasUppercase(p) && hasLowercase(p) && hasNumber(p) && hasSpecial(p) && hasMinLength(p);

    test('Valid password passes all criteria', () {
      expect(isValid('Password@123'), isTrue);
      expect(isValid('Finclub#2026!'), isTrue);
      expect(isValid('Admin\$Secure99'), isTrue);
    });

    test('Fails if missing uppercase', () {
      expect(isValid('password@123'), isFalse);
      expect(hasUppercase('password@123'), isFalse);
    });

    test('Fails if missing lowercase', () {
      expect(isValid('PASSWORD@123'), isFalse);
      expect(hasLowercase('PASSWORD@123'), isFalse);
    });

    test('Fails if missing number', () {
      expect(isValid('Password@Special'), isFalse);
      expect(hasNumber('Password@Special'), isFalse);
    });

    test('Fails if missing special character', () {
      expect(isValid('Password123'), isFalse);
      expect(hasSpecial('Password123'), isFalse);
    });

    test('Fails if shorter than 8 characters', () {
      expect(isValid('Pass@1'), isFalse);
      expect(hasMinLength('Pass@1'), isFalse);
    });
  });
}
