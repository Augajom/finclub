import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/seven_day_loan_result.dart';

/// Hero result showcase card displaying 7-day loan payment & breakdown with dynamic localization
class CalculationResultCard extends StatelessWidget {
  final SevenDayLoanResult result;
  final VoidCallback? onViewSchedule;
  final VoidCallback? onSavePlan;
  final VoidCallback? onApplyNow;

  const CalculationResultCard({
    super.key,
    required this.result,
    this.onViewSchedule,
    this.onSavePlan,
    this.onApplyNow,
  });

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header / 7-Day Total Highlight Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${langCtrl.tr('tenure')}: ${langCtrl.tr('tenureFixedDays')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  langCtrl.tr('totalRepaymentLabel'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(result.totalAmount, showSymbol: true),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Breakdown & 3 Stat columns
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatItem(
                      label: langCtrl.tr('principalLabel'),
                      value: CurrencyFormatter.format(result.principal),
                      color: AppColors.principalColor,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    Container(height: 36, width: 1, color: AppColors.divider),
                    _buildStatItem(
                      label: langCtrl.tr('dailyInterestLabel'),
                      value: '${CurrencyFormatter.format(result.interestPerDay)} ${langCtrl.tr('perDay')}',
                      color: AppColors.interestColor,
                      icon: Icons.trending_up_rounded,
                    ),
                    Container(height: 36, width: 1, color: AppColors.divider),
                    _buildStatItem(
                      label: langCtrl.tr('revenueFeeLabel'),
                      value: CurrencyFormatter.format(result.revenueFee),
                      color: AppColors.accent,
                      icon: Icons.receipt_long_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Actions row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewSchedule,
                        icon: const Icon(Icons.table_chart_outlined, size: 18),
                        label: Text(langCtrl.tr('viewScheduleBtn')),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (onSavePlan != null)
                      IconButton.filledTonal(
                        onPressed: onSavePlan,
                        icon: const Icon(Icons.bookmark_add_outlined),
                        tooltip: langCtrl.tr('savePlanBtn'),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                  ],
                ),
                if (onApplyNow != null) ...[
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: onApplyNow,
                    icon: const Icon(Icons.flash_on_rounded, size: 18),
                    label: Text(langCtrl.tr('apply7DayLoanBtn')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
