import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/seven_day_loan_result.dart';

/// Table displaying the 7-Day Day-by-Day loan schedule and repayment breakdown with dynamic localization
class SevenDayScheduleTable extends StatelessWidget {
  final SevenDayLoanResult result;

  const SevenDayScheduleTable({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final dailyInterest = result.interestPerDay;
    final principal = result.principal;
    final revenueFee = result.revenueFee;
    final totalAmount = result.totalAmount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(17),
                topRight: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 54,
                  child: Text(
                    langCtrl.tr('colDay'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    langCtrl.tr('colDailyInterest'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    langCtrl.tr('colAccruedInterest'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    langCtrl.tr('colPaymentDue'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Days 1 through 7
          ...List.generate(7, (index) {
            final day = index + 1;
            final isLastDay = (day == 7);
            final cumulativeInterest = ((dailyInterest * day) * 100).roundToDouble() / 100.0;
            final paymentDueToday = isLastDay ? totalAmount : 0.0;

            return Container(
              color: isLastDay ? AppColors.secondary.withValues(alpha: 0.06) : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Day Badge
                  SizedBox(
                    width: 54,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLastDay ? AppColors.secondary : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${langCtrl.tr('dayPrefix')} $day',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isLastDay ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Daily Interest
                  Expanded(
                    flex: 2,
                    child: Text(
                      CurrencyFormatter.format(dailyInterest, showSymbol: false),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.interestColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),

                  // Cumulative Interest
                  Expanded(
                    flex: 2,
                    child: Text(
                      CurrencyFormatter.format(cumulativeInterest, showSymbol: false),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),

                  // Payment Due
                  Expanded(
                    flex: 3,
                    child: isLastDay
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.format(paymentDueToday),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.secondary,
                                ),
                              ),
                              Text(
                                langCtrl.tr('dayDue'),
                                style: const TextStyle(fontSize: 9, color: AppColors.secondary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          )
                        : const Text(
                            '-',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            textAlign: TextAlign.right,
                          ),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 1, color: AppColors.divider),

          // Total Summary Box at Bottom
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(17),
                bottomRight: Radius.circular(17),
              ),
            ),
            child: Column(
              children: [
                _buildSummaryLine(
                  langCtrl.isThai ? '1. เงินต้นที่ยืม' : '1. Principal',
                  CurrencyFormatter.format(principal),
                  AppColors.principalColor,
                ),
                const SizedBox(height: 4),
                _buildSummaryLine(
                  langCtrl.isThai ? '2. ดอกเบี้ยรวม 7 วัน' : '2. 7-Day Interest',
                  CurrencyFormatter.format(result.totalInterest),
                  AppColors.interestColor,
                ),
                const SizedBox(height: 4),
                _buildSummaryLine(
                  langCtrl.isThai ? '3. ค่าดำเนินการ' : '3. Service Fee',
                  CurrencyFormatter.format(revenueFee),
                  AppColors.accent,
                ),
                const Divider(height: 12, color: AppColors.divider),
                _buildSummaryLine(
                  langCtrl.isThai ? '4. ยอดรวมที่ต้องชำระ' : '4. Total Repayment',
                  CurrencyFormatter.format(totalAmount),
                  AppColors.secondary,
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String title, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isBold ? 12 : 11,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
