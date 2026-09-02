import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/seven_day_loan_result.dart';
import '../widgets/seven_day_schedule_table.dart';

/// Detailed repayment schedule screen for 7-Day Loan with dynamic localization
class ScheduleDetailScreen extends StatelessWidget {
  final SevenDayLoanResult result;

  const ScheduleDetailScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langCtrl.tr('scheduleDetailTitle')),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(langCtrl.tr('shareSuccess')),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.share_rounded),
            tooltip: langCtrl.tr('shareSchedule'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              langCtrl.tr('principalLabel'),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              CurrencyFormatter.format(result.principal),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              langCtrl.tr('totalRepaymentLabel'),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              CurrencyFormatter.format(result.totalAmount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildWhiteStat(langCtrl.tr('tenure'), langCtrl.tr('tenureFixedDays'))),
                      Expanded(child: _buildWhiteStat(langCtrl.tr('dailyInterestLabel'), '${CurrencyFormatter.format(result.interestPerDay)} ${langCtrl.tr('perDay')}')),
                      Expanded(child: _buildWhiteStat(langCtrl.tr('revenueFeeLabel'), CurrencyFormatter.format(result.revenueFee))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Amortization explanation box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppColors.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      langCtrl.isThai
                          ? 'สินเชื่อระยะเวลาผ่อนชำระคงที่ 7 วัน: คิดดอกเบี้ยรายวันตามจริง (สูงสุด 35.80% ต่อปี) รวมกับค่าดำเนินการ และชำระคืนครบถ้วนในวันที่ 7'
                          : 'Fixed 7-day tenure micro loan: transparent daily interest (max 35.80% p.a.) plus processing fee, due on day 7.',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Schedule Table
            Text(
              langCtrl.tr('scheduleDetailHeader'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SevenDayScheduleTable(result: result),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteStat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
