import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../domain/entities/user_entity.dart';
import '../controllers/auth_controller.dart';
import '../widgets/pin_dots_indicator.dart';
import '../widgets/pin_keypad_widget.dart';
import 'welcome_auth_screen.dart';

/// Screen for authenticating with 6-digit PIN or Biometrics on app launch
class PinLockScreen extends StatefulWidget {
  final UserEntity? user;
  final VoidCallback? onUnlocked;

  const PinLockScreen({
    super.key,
    this.user,
    this.onUnlocked,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _pin = '';
  bool _hasError = false;
  String? _errorMessage;
  bool _hasBiometric = false;
  UserEntity? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserAndCheckBiometrics();
  }

  void _loadUserAndCheckBiometrics() async {
    _currentUser = widget.user ?? await SessionService.instance.getUser();
    final isBioEnabled = await SessionService.instance.isBiometricEnabled();
    final canBio = await BiometricService.instance.canCheckBiometrics() ||
        await BiometricService.instance.isDeviceSupported();

    setState(() {
      _hasBiometric = isBioEnabled && canBio;
    });

    // Auto-prompt biometrics if enabled
    if (_hasBiometric) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerBiometricAuth();
      });
    }
  }

  void _triggerBiometricAuth({bool isManual = false}) async {
    final langCtrl = LanguageProvider.of(context);
    final authenticated = await BiometricService.instance.authenticate(
      reason: langCtrl.tr('biometricReason'),
    );

    if (authenticated && mounted) {
      _unlockSuccess();
    } else if (isManual && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            langCtrl.isThai
                ? 'ไม่พบลายนิ้วมือที่ลงทะเบียนไว้ หรือยกเลิกการสแกน (กรุณาตั้งค่าลายนิ้วมือใน Settings ของเครื่อง)'
                : 'No fingerprint enrolled or canceled (Please register fingerprint in device Settings)',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onDigitPressed(String digit) {
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
    }

    if (_pin.length < 6) {
      setState(() {
        _pin += digit;
      });

      if (_pin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
    }

    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _verifyPin() async {
    final langCtrl = LanguageProvider.of(context);
    final isValid = await SessionService.instance.validatePin(_pin);

    if (isValid) {
      _unlockSuccess();
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = langCtrl.tr('pinInvalid');
        _pin = '';
      });
    }
  }

  void _unlockSuccess() async {
    // Quick verification that user still exists in database
    final dbUser = await ApiService.instance.getMe();
    if (!mounted) return;

    if (dbUser == null) {
      await SessionService.instance.clearSession();
      if (mounted) {
        final langCtrl = LanguageProvider.of(context);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeAuthScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              langCtrl.isThai
                  ? 'ไม่พบบัญชีผู้ใช้ในระบบ หรือบัญชีถูกลบแล้ว กรุณาเข้าสู่ระบบใหม่'
                  : 'User account not found. Please log in again.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (widget.onUnlocked != null) {
      widget.onUnlocked!();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  void _onSwitchAccount() async {
    final authCtrl = AuthController.of(context);
    await authCtrl.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeAuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final email = _currentUser?.email ?? 'member@finclub.com';
    final avatarUrl = _currentUser?.formattedAvatarUrl;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Profile Identity & PIN Dots
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: ClipOval(
                          child: avatarUrl != null && avatarUrl.isNotEmpty
                              ? Image.network(
                                  avatarUrl,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.person_rounded,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        langCtrl.tr('pinTitle'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 6 Dots Visual Feedback
                      PinDotsIndicator(
                        pinLength: _pin.length,
                        maxLength: 6,
                        hasError: _hasError,
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Numeric Keypad & Biometrics
                  Column(
                    children: [
                      PinKeypadWidget(
                        onDigitPressed: _onDigitPressed,
                        onDeletePressed: _onDeletePressed,
                        onBiometricPressed: _hasBiometric ? () => _triggerBiometricAuth(isManual: true) : null,
                        showBiometric: _hasBiometric,
                      ),
                      const SizedBox(height: 14),

                      // Switch Account / Logout link
                      TextButton(
                        onPressed: _onSwitchAccount,
                        child: Text(
                          langCtrl.tr('switchAccount'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
