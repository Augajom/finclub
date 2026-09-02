import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/language_controller.dart';

/// Interest rate configuration and calculation mode toggle card with dynamic localization
class InterestRateCard extends StatefulWidget {
  final double currentRate;
  final bool isReducingBalance;
  final ValueChanged<double> onRateChanged;
  final ValueChanged<bool> onModeChanged;

  const InterestRateCard({
    super.key,
    required this.currentRate,
    required this.isReducingBalance,
    required this.onRateChanged,
    required this.onModeChanged,
  });

  @override
  State<InterestRateCard> createState() => _InterestRateCardState();
}

class _InterestRateCardState extends State<InterestRateCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            langCtrl.tr('interestRate'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${widget.currentRate.toStringAsFixed(2)}% ${langCtrl.isThai ? 'ต่อปี' : 'p.a.'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        langCtrl.isThai
                            ? 'อัตราดอกเบี้ยเป็นไปตามหลักเกณฑ์และเงื่อนไขของผลิตภัณฑ์'
                            : 'Interest rate adheres to regulatory guidelines and terms',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    Icons.tune_rounded,
                    color: _isExpanded ? AppColors.primary : AppColors.textSecondary,
                  ),
                  tooltip: langCtrl.isThai ? 'ปรับแต่งดอกเบี้ยและวิธีคำนวณ' : 'Customize interest and mode',
                ),
              ],
            ),
          ),

          // Collapsible advanced settings (Sliders & Mode Toggle)
          if (_isExpanded) ...[
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calculation Type Switch
                  Text(
                    langCtrl.isThai ? 'รูปแบบการคิดดอกเบี้ย' : 'Calculation Method',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeOption(
                          title: langCtrl.isThai ? 'ลดต้นลดดอก (แนะนำ)' : 'Reducing Balance',
                          subtitle: 'Effective Rate',
                          isSelected: widget.isReducingBalance,
                          onTap: () => widget.onModeChanged(true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTypeOption(
                          title: langCtrl.isThai ? 'ดอกเบี้ยคงที่' : 'Flat Rate',
                          subtitle: 'Fixed Rate',
                          isSelected: !widget.isReducingBalance,
                          onTap: () => widget.onModeChanged(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Slider for Interest Rate
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        langCtrl.isThai ? 'ปรับอัตราดอกเบี้ยต่อปี' : 'Adjust Annual Interest Rate',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${widget.currentRate.toStringAsFixed(2)}% ${langCtrl.isThai ? '/ ปี' : '/ year'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: widget.currentRate.clamp(
                      AppConstants.minInterestRate,
                      AppConstants.maxInterestRate,
                    ),
                    min: AppConstants.minInterestRate,
                    max: AppConstants.maxInterestRate,
                    divisions: 119,
                    onChanged: (val) {
                      final rounded = (val * 100).roundToDouble() / 100.0;
                      widget.onRateChanged(rounded);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('12.00%', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      TextButton(
                        onPressed: () => widget.onRateChanged(AppConstants.maxInterestRate),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          langCtrl.isThai ? 'รีเซ็ตเป็น 35.80% (สูงสุด)' : 'Reset to 35.80% (Max)',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 16,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 22),
              child: Text(
                subtitle,
                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
