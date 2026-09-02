import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../widgets/pin_dots_indicator.dart';
import '../widgets/pin_keypad_widget.dart';

/// Screen for creating and confirming a 6-digit PIN code with Biometric prompt
class PinSetupScreen extends StatefulWidget {
  final VoidCallback? onPinSetupCompleted;

  const PinSetupScreen({
    super.key,
    this.onPinSetupCompleted,
  });

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirmStep = false;
  bool _hasError = false;
  String? _errorMessage;

  void _onDigitPressed(String digit) {
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
    }

    if (!_isConfirmStep) {
      if (_firstPin.length < 6) {
        setState(() {
          _firstPin += digit;
        });

        if (_firstPin.length == 6) {
          Future.delayed(const Duration(milliseconds: 250), () {
            if (mounted) {
              setState(() {
                _isConfirmStep = true;
              });
            }
          });
        }
      }
    } else {
      if (_confirmPin.length < 6) {
        setState(() {
          _confirmPin += digit;
        });

        if (_confirmPin.length == 6) {
          _verifyAndSavePin();
        }
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

    if (!_isConfirmStep) {
      if (_firstPin.isNotEmpty) {
        setState(() {
          _firstPin = _firstPin.substring(0, _firstPin.length - 1);
        });
      }
    } else {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        });
      } else {
        setState(() {
          _isConfirmStep = false;
          _firstPin = '';
        });
      }
    }
  }

  void _verifyAndSavePin() async {
    final langCtrl = LanguageProvider.of(context);

    if (_firstPin == _confirmPin) {
      await SessionService.instance.savePin(_firstPin);

      if (!mounted) return;

      // Check if device supports Biometrics
      final canBiometrics = await BiometricService.instance.canCheckBiometrics() ||
          await BiometricService.instance.isDeviceSupported();

      if (canBiometrics && mounted) {
        _showBiometricOptInDialog();
      } else {
        _proceedToDashboard();
      }
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = langCtrl.tr('pinNotMatch');
        _firstPin = '';
        _confirmPin = '';
        _isConfirmStep = false;
      });
    }
  }

  void _showBiometricOptInDialog() {
    final langCtrl = LanguageProvider.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fingerprint_rounded, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              langCtrl.tr('biometricPromptTitle'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              langCtrl.tr('biometricPromptSubtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await SessionService.instance.setBiometricEnabled(true);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  _proceedToDashboard();
                },
                icon: const Icon(Icons.fingerprint_rounded, size: 20),
                label: Text(langCtrl.tr('enableBiometric'), style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                await SessionService.instance.setBiometricEnabled(false);
                if (ctx.mounted) Navigator.of(ctx).pop();
                _proceedToDashboard();
              },
              child: Text(langCtrl.tr('skipBiometric')),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToDashboard() {
    if (widget.onPinSetupCompleted != null) {
      widget.onPinSetupCompleted!();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final currentPinLength = _isConfirmStep ? _confirmPin.length : _firstPin.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(langCtrl.tr('pinSetupTitle')),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header & Visual Indicator
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isConfirmStep ? Icons.lock_clock_rounded : Icons.lock_outline_rounded,
                          size: 38,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isConfirmStep
                            ? langCtrl.tr('pinConfirmTitle')
                            : langCtrl.tr('pinSetupTitle'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isConfirmStep
                            ? langCtrl.tr('pinConfirmSubtitle')
                            : langCtrl.tr('pinSetupSubtitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 28),

                      // 6 Dots
                      PinDotsIndicator(
                        pinLength: currentPinLength,
                        maxLength: 6,
                        hasError: _hasError,
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),

                  // Numeric Keypad
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PinKeypadWidget(
                      onDigitPressed: _onDigitPressed,
                      onDeletePressed: _onDeletePressed,
                      showBiometric: false,
                    ),
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
