import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fintech/core/services/session_service.dart';
import 'package:fintech/features/auth/domain/entities/user_entity.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SessionService and PIN Security Tests', () {
    test('Saves and validates 6-digit PIN correctly', () async {
      final session = SessionService.instance;

      expect(await session.hasPin(), isFalse);

      await session.savePin('123456');

      expect(await session.hasPin(), isTrue);
      expect(await session.validatePin('123456'), isTrue);
      expect(await session.validatePin('654321'), isFalse);
      expect(await session.validatePin('12345'), isFalse);

      await session.removePin();
      expect(await session.hasPin(), isFalse);
    });

    test('Toggles biometric preference correctly', () async {
      final session = SessionService.instance;

      expect(await session.isBiometricEnabled(), isFalse);

      await session.setBiometricEnabled(true);
      expect(await session.isBiometricEnabled(), isTrue);

      await session.setBiometricEnabled(false);
      expect(await session.isBiometricEnabled(), isFalse);
    });

    test('Stores and restores user session for auto-login', () async {
      final session = SessionService.instance;

      expect(await session.isLoggedIn(), isFalse);

      const user = UserEntity(
        id: 1,
        email: 'test@finclub.com',
        hasAcceptedTerms: true,
      );

      await session.saveSession(token: 'mock_jwt_token_123', user: user);

      expect(await session.isLoggedIn(), isTrue);
      expect(await session.getToken(), 'mock_jwt_token_123');

      final savedUser = await session.getUser();
      expect(savedUser?.email, 'test@finclub.com');
      expect(savedUser?.hasAcceptedTerms, isTrue);

      await session.clearSession();
      expect(await session.isLoggedIn(), isFalse);
    });

    test('Invalidates session and PIN completely when user is removed', () async {
      final session = SessionService.instance;

      const user = UserEntity(
        id: 99,
        email: 'deleted@finclub.com',
        hasAcceptedTerms: true,
      );

      await session.saveSession(token: 'token_to_remove', user: user);
      await session.savePin('999999');
      await session.setBiometricEnabled(true);

      expect(await session.isLoggedIn(), isTrue);
      expect(await session.hasPin(), isTrue);
      expect(await session.isBiometricEnabled(), isTrue);

      // Invalidate session (as done when user is deleted from DB)
      await session.clearSession();

      expect(await session.isLoggedIn(), isFalse);
      expect(await session.getUser(), isNull);
      expect(await session.getToken(), isNull);
      expect(await session.hasPin(), isFalse);
      expect(await session.isBiometricEnabled(), isFalse);
    });
  });
}
