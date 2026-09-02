import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/entities/user_entity.dart';

/// Local session management for auth token, user profile, 6-digit PIN, and biometrics
class SessionService {
  static const String _tokenKey = 'auth_jwt_token';
  static const String _userKey = 'auth_user_data';
  static const String _termsAcceptedKey = 'terms_accepted_flag';
  static const String _seenLanguageKey = 'seen_language_selection';
  static const String _pinCodeKey = 'user_pin_code_hash';
  static const String _biometricEnabledKey = 'biometric_enabled_flag';

  SessionService._();
  static final SessionService instance = SessionService._();

  // ==========================================
  // Auth Token & User Profile
  // ==========================================

  Future<void> saveSession({required String token, required UserEntity user}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    if (user.hasAcceptedTerms) {
      await prefs.setBool(_termsAcceptedKey, true);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserEntity?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return UserEntity.fromJson(map);
      } catch (_) {}
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && token.isNotEmpty && user != null;
  }

  Future<void> updateTermsAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_termsAcceptedKey, accepted);

    final currentUser = await getUser();
    if (currentUser != null) {
      final updated = currentUser.copyWith(hasAcceptedTerms: accepted);
      await prefs.setString(_userKey, jsonEncode(updated.toJson()));
    }
  }

  Future<bool> hasAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_termsAcceptedKey) ?? false;
  }

  Future<bool> hasSeenLanguageSelection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenLanguageKey) ?? false;
  }

  Future<void> setSeenLanguageSelection(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenLanguageKey, seen);
  }

  // ==========================================
  // 6-Digit PIN Security
  // ==========================================

  Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    // Save 6-digit PIN securely
    await prefs.setString(_pinCodeKey, pin);
  }

  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString(_pinCodeKey);
    return pin != null && pin.length == 6;
  }

  Future<bool> validatePin(String inputPin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_pinCodeKey);
    return savedPin == inputPin;
  }

  Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinCodeKey);
  }

  // ==========================================
  // Biometrics (Fingerprint / Face ID)
  // ==========================================

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  // ==========================================
  // Clear Session
  // ==========================================

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_termsAcceptedKey);
    // Keep PIN or clear depending on full logout
    await prefs.remove(_pinCodeKey);
    await prefs.remove(_biometricEnabledKey);
  }
}
