import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/saved_loan_item.dart';
import '../../domain/entities/seven_day_loan_result.dart';
import '../controllers/loan_controller.dart';
import 'schedule_detail_screen.dart';

/// Saved 7-Day loan plans management screen (Real DB per user with dynamic localization)
class SavedLoansScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCalculator;

  const SavedLoansScreen({
    super.key,
    this.onNavigateToCalculator,
  });

  @override
  State<SavedLoansScreen> createState() => _SavedLoansScreenState();
}

class _SavedLoansScreenState extends State<SavedLoansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        LoanControllerProvider.of(context).fetchSavedPlans();
      }
    });
  }

  void _showDeleteConfirmDialog(BuildContext context, SavedLoanItem item, LoanController controller) async {
    final langCtrl = LanguageProvider.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.all(20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                langCtrl.tr('deletePlanModalTitle'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Text(
          langCtrl.isThai
              ? 'คุณต้องการลบแผน "${item.title}" ออกจากฐานข้อมูลใช่หรือไม่?\n\nเมื่อลบแล้วจะไม่สามารถกู้คืนข้อมูลนี้ได้'
              : 'Are you sure you want to delete "${item.title}" from the database?\n\nThis action cannot be undone.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      langCtrl.tr('cancel'),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      langCtrl.tr('deleteConfirmBtn'),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await controller.deleteSavedPlan(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    langCtrl.isThai
                        ? 'ลบแผน "${item.title}" ออกจากฐานข้อมูลเรียบร้อยแล้ว'
                        : 'Plan "${item.title}" deleted from database successfully',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final controller = LoanControllerProvider.of(context);
    final savedLoans = controller.savedLoans;
    final isLoading = controller.isLoadingPlans;

    return Scaffold(
      appBar: AppBar(
        title: Text(langCtrl.tr('savedLoansTitle')),
        actions: [
          IconButton(
            onPressed: () => controller.fetchSavedPlans(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: langCtrl.tr('refreshData'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isLoading && savedLoans.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => controller.fetchSavedPlans(),
              child: savedLoans.isEmpty
                  ? _buildEmptyState(context, langCtrl)
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Overview Stats Header
                          _buildOverviewCards(savedLoans, langCtrl),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                langCtrl.tr('savedPlansHeader'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // List of Saved 7-Day Loan Plans
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: savedLoans.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = savedLoans[index];
                              return _buildSavedLoanCard(context, item, controller, langCtrl);
                            },
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, LanguageController langCtrl) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_border_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    langCtrl.tr('emptySavedTitle'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    langCtrl.tr('emptySavedSubtitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.onNavigateToCalculator != null)
                    ElevatedButton.icon(
                      onPressed: widget.onNavigateToCalculator,
                      icon: const Icon(Icons.table_chart_outlined),
                      label: Text(langCtrl.tr('goToScheduleBtn')),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildOverviewCards(List<SavedLoanItem> list, LanguageController langCtrl) {
    final double totalAmount = list.fold(0.0, (sum, e) => sum + e.loanAmount);
    final double avgAmount = list.isNotEmpty ? totalAmount / list.length : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langCtrl.tr('totalPlansCount'),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${list.length} ${langCtrl.tr('itemsUnit')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langCtrl.tr('avgPlanAmount'),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(avgAmount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedLoanCard(
    BuildContext context,
    SavedLoanItem item,
    LoanController controller,
    LanguageController langCtrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title, 7-Day Badge & Delete Button with Confirmation Dialog
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmDialog(context, item, controller),
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                tooltip: langCtrl.tr('deletePlanTooltip'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          if (item.note != null && item.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.note!,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],

          const Divider(height: 16, color: AppColors.divider),

          // 4 Key Metrics (เงินต้น, ดอกเบี้ย/วัน, ค่าดำเนินการ, ยอด Total รวม)
          Row(
            children: [
              Expanded(child: _buildMiniMetric(langCtrl.tr('principalLabel'), CurrencyFormatter.format(item.loanAmount), AppColors.principalColor)),
              Expanded(child: _buildMiniMetric(langCtrl.tr('dailyInterestLabel'), '${CurrencyFormatter.format(item.interestPerDay)} ${langCtrl.tr('perDay')}', AppColors.interestColor)),
              Expanded(child: _buildMiniMetric(langCtrl.tr('revenueFeeLabel'), CurrencyFormatter.format(item.revenueFee), AppColors.accent)),
              Expanded(child: _buildMiniMetric(langCtrl.tr('totalRepaymentLabel'), CurrencyFormatter.format(item.totalAmount), AppColors.secondary, isHighlight: true)),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons - Symmetrical height and dimensions
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final res = SevenDayLoanResult.compute(
                        principal: item.loanAmount,
                        annualRate: item.annualInterestRate,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ScheduleDetailScreen(result: res),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month_outlined, size: 16),
                    label: Text(langCtrl.tr('viewScheduleBtn'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.loadSavedPlan(item);
                      if (widget.onNavigateToCalculator != null) {
                        widget.onNavigateToCalculator!();
                      } else {
                        Navigator.of(context).pop();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            langCtrl.isThai
                                ? 'โหลด "${item.title}" เข้าเครื่องคำนวณแล้ว'
                                : 'Loaded "${item.title}" into calculator',
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 16),
                    label: Text(langCtrl.tr('usePlanBtn'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 12 : 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
