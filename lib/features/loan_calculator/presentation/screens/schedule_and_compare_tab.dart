import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/seven_day_loan_result.dart';
import '../controllers/loan_controller.dart';
import '../widgets/seven_day_schedule_table.dart';

/// Tab 2: Repayment Schedule for 7-Day Fixed Micro Loan with dynamic localization
class ScheduleAndCompareTab extends StatelessWidget {
  final VoidCallback? onNavigateToCalculator;

  const ScheduleAndCompareTab({
    super.key,
    this.onNavigateToCalculator,
  });

  void _showSavePlanDialog(BuildContext context, LoanController controller, SevenDayLoanResult result) {
    final langCtrl = LanguageProvider.of(context);

    final titleController = TextEditingController(
      text: langCtrl.isThai
          ? 'แผนสินเชื่อ 7 วัน ฿${result.principal.toInt()}'
          : '7-Day Loan Plan ฿${result.principal.toInt()}',
    );
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.bookmark_added_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                langCtrl.tr('savePlanModalTitle'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              langCtrl.tr('savePlanModalSubtitle'),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: langCtrl.tr('planNameLabel'),
                hintText: langCtrl.tr('planNameHint'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: langCtrl.tr('planNoteLabel'),
                hintText: langCtrl.tr('planNoteHint'),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Text(langCtrl.tr('cancel')),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final note = noteController.text.trim();
                      Navigator.of(dialogCtx).pop();

                      await controller.save7DayLoanPlan(
                        result: result,
                        customTitle: title.isNotEmpty ? title : null,
                        note: note.isNotEmpty ? note : null,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    langCtrl.isThai
                                        ? 'บันทึกแผน "${title.isNotEmpty ? title : 'เรียบร้อยแล้ว'}"'
                                        : 'Plan "${title.isNotEmpty ? title : 'Saved'}" successfully',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(langCtrl.tr('confirm')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final controller = LoanControllerProvider.of(context);
    final result = controller.sevenDayResult;

    return Scaffold(
      appBar: AppBar(
        title: Text(langCtrl.tr('scheduleTabTitle')),
        actions: [
          IconButton(
            onPressed: () => _showSavePlanDialog(context, controller, result),
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: langCtrl.tr('savePlanBtn'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Current 7-Day Summary Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${langCtrl.tr('tenure')}: ${langCtrl.tr('tenureFixedDays')}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${langCtrl.tr('interestRate')} ${result.annualInterestRate.toStringAsFixed(2)}% ${langCtrl.isThai ? 'ต่อปี' : 'p.a.'}',
                        style: const TextStyle(color: AppColors.accentLight, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

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
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(result.principal),
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
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
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(result.totalAmount),
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${langCtrl.tr('dailyInterestLabel')}: ${CurrencyFormatter.format(result.interestPerDay)} ${langCtrl.tr('perDay')}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${langCtrl.tr('revenueFeeLabel')}: ${CurrencyFormatter.format(result.revenueFee)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. Quick Preset Amount Chips
            Text(
              langCtrl.isThai ? 'เลือกวงเงินเพื่อดูตารางผ่อนชำระ 7 วัน:' : 'Select loan amount to view 7-day schedule:',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AppConstants.loanAmountPresets.map((preset) {
                  final isSelected = (preset == controller.loanAmount);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        '฿${preset.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.cardBackground,
                      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                      showCheckmark: false,
                      onSelected: (selected) {
                        if (selected) controller.setLoanAmount(preset);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Day-by-Day 7-Day Repayment Breakdown Table
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  langCtrl.tr('scheduleDetailHeader'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SevenDayScheduleTable(result: result),
            const SizedBox(height: 20),

            // 4. Action Buttons (Full width for single-line typography)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onNavigateToCalculator,
                icon: const Icon(Icons.flash_on_rounded, size: 20),
                label: Text(
                  langCtrl.tr('apply7DayLoanBtn'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => _showSavePlanDialog(context, controller, result),
                icon: const Icon(Icons.bookmark_border_rounded, size: 18),
                label: Text(
                  langCtrl.tr('savePlanBtn'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
