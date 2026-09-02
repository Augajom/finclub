import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Modern 3x4 numeric keypad for 6-digit PIN entry
class PinKeypadWidget extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;

  const PinKeypadWidget({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.onBiometricPressed,
    this.showBiometric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Left Action: Biometrics
            SizedBox(
              key: const Key('keypad_biometric'),
              width: 72,
              height: 72,
              child: showBiometric && onBiometricPressed != null
                  ? InkWell(
                      onTap: onBiometricPressed,
                      borderRadius: BorderRadius.circular(36),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.fingerprint_rounded,
                          size: 38,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Middle: 0
            _buildKeypadButton('0'),

            // Right Action: Backspace
            SizedBox(
              key: const Key('keypad_backspace'),
              width: 72,
              height: 72,
              child: InkWell(
                onTap: onDeletePressed,
                borderRadius: BorderRadius.circular(36),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.04),
                  ),
                  child: const Icon(
                    Icons.backspace_outlined,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) => _buildKeypadButton(digit)).toList(),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return SizedBox(
      key: Key('keypad_$digit'),
      width: 72,
      height: 72,
      child: InkWell(
        onTap: () => onDigitPressed(digit),
        borderRadius: BorderRadius.circular(36),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.04),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
