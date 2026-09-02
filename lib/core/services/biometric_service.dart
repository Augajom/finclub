import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Service managing device biometric hardware (Fingerprint, Face ID)
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks whether the device hardware supports biometrics
  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint('[BiometricService] isDeviceSupported error: $e');
      return false;
    }
  }

  /// Checks whether biometrics can be checked
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      debugPrint('[BiometricService] canCheckBiometrics error: $e');
      return false;
    }
  }

  /// Lists available biometric types on device (e.g. fingerprint, face, iris)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('[BiometricService] getAvailableBiometrics error: $e');
      return [];
    }
  }

  /// Prompts system biometric scanner dialog
  Future<bool> authenticate({
    String reason = 'สแกนลายนิ้วมือเพื่อยืนยันตัวตนเข้าสู่ระบบ Finclub',
  }) async {
    try {
      final isSupported = await isDeviceSupported();
      final canCheck = await canCheckBiometrics();
      if (!isSupported && !canCheck) {
        debugPrint('[BiometricService] Biometrics not supported on this device');
        return false;
      }

      return await _auth.authenticate(
        localizedReason: reason,
      );
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] PlatformException: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[BiometricService] General error: $e');
      return false;
    }
  }
}
