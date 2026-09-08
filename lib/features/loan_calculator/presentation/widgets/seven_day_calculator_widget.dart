import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/seven_day_loan_result.dart';

/// Interactive 7-Day Fixed Loan Calculator Widget with Confirmation Dialog
class SevenDayCalculatorWidget extends StatefulWidget {
  final double initialAmount;
  final VoidCallback? onLoanApplied;

  const SevenDayCalculatorWidget({
    super.key,
    this.initialAmount = 20000.0,
    this.onLoanApplied,
  });

  @override
  State<SevenDayCalculatorWidget> createState() => _SevenDayCalculatorWidgetState();
}

class _SevenDayCalculatorWidgetState extends State<SevenDayCalculatorWidget> {
  late double _currentAmount;
  late SevenDayLoanResult _calculationResult;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _currentAmount = widget.initialAmount;
    _recalculate();
  }

  void _recalculate() {
    _calculationResult = SevenDayLoanResult.compute(
      principal: _currentAmount,
      annualRate: AppConstants.defaultInterestRate,
    );
  }

  void _onAmountChanged(double val) {
    setState(() {
      _currentAmount = val.clamp(AppConstants.minLoanAmount, AppConstants.maxLoanAmount);
      _recalculate();
    });
  }

  void _confirmAndApplyLoan() async {
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
                color: AppColors.secondary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.help_outline_rounded, color: AppColors.secondary, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                langCtrl.isThai ? 'ยืนยันการขอกู้ยืมสินเชื่อ' : 'Confirm Loan Application',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              langCtrl.tr('confirmApplyMsg'),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildReceiptRow(langCtrl.tr('principalLabel'), CurrencyFormatter.format(_calculationResult.principal)),
                  const SizedBox(height: 6),
                  _buildReceiptRow(langCtrl.tr('tenure'), langCtrl.tr('tenureFixedDays')),
                  const SizedBox(height: 6),
                  _buildReceiptRow(langCtrl.tr('dailyInterestLabel'), '${CurrencyFormatter.format(_calculationResult.interestPerDay)} ${langCtrl.tr('perDay')}'),
                  const SizedBox(height: 6),
                  _buildReceiptRow(langCtrl.tr('revenueFeeLabel'), CurrencyFormatter.format(_calculationResult.revenueFee)),
                  const SizedBox(height: 6),
                  _buildReceiptRow(langCtrl.tr('dueDateLabel'), _calculationResult.getDueDateFormatted(isThai: langCtrl.isThai), isHighlight: true),
                  const Divider(height: 14, color: AppColors.divider),
                  _buildReceiptRow(
                    langCtrl.tr('totalRepaymentLabel'),
                    CurrencyFormatter.format(_calculationResult.totalAmount),
                    isTotal: true,
                  ),
                ],
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
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      langCtrl.tr('confirmApplyBtn'),
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

    if (confirmed == true) {
      _applyLoan();
    }
  }

  void _applyLoan() async {
    final langCtrl = LanguageProvider.of(context);
    setState(() => _isApplying = true);

    try {
      final res = await ApiService.instance.apply7DaysLoan(
        principal: _currentAmount,
        annualRate: AppConstants.defaultInterestRate,
      );

      if (!mounted) return;
      setState(() => _isApplying = false);

      _showSuccessReceipt(res, langCtrl);
      widget.onLoanApplied?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isApplying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showSuccessReceipt(SevenDayLoanResult res, LanguageController langCtrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              langCtrl.tr('applySuccessTitle'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              langCtrl.tr('applySuccessMsg'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Receipt Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildReceiptRow(langCtrl.tr('principalLabel'), CurrencyFormatter.format(res.principal)),
                  const SizedBox(height: 8),
                  _buildReceiptRow(langCtrl.tr('dailyInterestLabel'), '${CurrencyFormatter.format(res.interestPerDay)} ${langCtrl.tr('perDay')}'),
                  const SizedBox(height: 8),
                  _buildReceiptRow(langCtrl.tr('sevenDaysInterestLabel'), CurrencyFormatter.format(res.totalInterest)),
                  const SizedBox(height: 8),
                  _buildReceiptRow(langCtrl.tr('revenueFeeLabel'), CurrencyFormatter.format(res.revenueFee)),
                  const Divider(height: 16, color: AppColors.divider),
                  _buildReceiptRow(
                    langCtrl.tr('totalRepaymentLabel'),
                    CurrencyFormatter.format(res.totalAmount),
                    isTotal: true,
                  ),
                  const SizedBox(height: 8),
                  _buildReceiptRow(langCtrl.tr('dueDateLabel'), res.getDueDateFormatted(isThai: langCtrl.isThai), isHighlight: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(langCtrl.tr('ok')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isTotal = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 13 : 11,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 15 : 12,
            fontWeight: isTotal || isHighlight ? FontWeight.w900 : FontWeight.w700,
            color: isTotal
                ? AppColors.primary
                : isHighlight
                    ? AppColors.accent
                    : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Amount Control Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          langCtrl.tr('selectAmount'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          langCtrl.tr('amountRange'),
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      CurrencyFormatter.format(_currentAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.border,
                  thumbColor: AppColors.primary,
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _currentAmount,
                  min: AppConstants.minLoanAmount,
                  max: AppConstants.maxLoanAmount,
                  divisions: 49,
                  onChanged: _onAmountChanged,
                ),
              ),

              // Min / Max
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('฿1,000', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text('฿50,000', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Presets
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AppConstants.loanAmountPresets.map((preset) {
                    final isSelected = (preset == _currentAmount);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          '฿${preset.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (selected) _onAmountChanged(preset);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Fixed 7-Day Loan Breakdown Hero Showcase Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Highlight Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            langCtrl.tr('tenureFixedBadge'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      langCtrl.tr('totalRepaymentLabel'),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(_calculationResult.totalAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${langCtrl.tr('dueDateLabel')} ${_calculationResult.getDueDateFormatted(isThai: langCtrl.isThai)}',
                      style: const TextStyle(color: AppColors.accentLight, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // 4 Required Values List:
              // 1. เงินต้นที่ยืม
              // 2. ดอกเบี้ยต่อวัน
              // 3. ค่าดำเนินการหรือ enue
              // 4. ยอด Total รวม
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildMetricRow(
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.principalColor,
                      label: langCtrl.tr('principalLabel'),
                      sub: langCtrl.isThai ? 'วงเงินที่ได้รับโอนเข้าบัญชี' : 'Amount transferred to account',
                      value: CurrencyFormatter.format(_calculationResult.principal),
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildMetricRow(
                      icon: Icons.trending_up_rounded,
                      color: AppColors.interestColor,
                      label: langCtrl.tr('dailyInterestLabel'),
                      sub: '${langCtrl.tr('sevenDaysInterestLabel')}: ${CurrencyFormatter.format(_calculationResult.totalInterest)}',
                      value: '${CurrencyFormatter.format(_calculationResult.interestPerDay)} ${langCtrl.tr('perDay')}',
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildMetricRow(
                      icon: Icons.receipt_long_outlined,
                      color: AppColors.accent,
                      label: langCtrl.tr('revenueFeeLabel'),
                      sub: langCtrl.isThai ? 'ค่าบริการระบบและค่าดำเนินการ' : 'Platform processing fee',
                      value: CurrencyFormatter.format(_calculationResult.revenueFee),
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildMetricRow(
                      icon: Icons.payments_rounded,
                      color: AppColors.secondary,
                      label: langCtrl.tr('totalRepaymentLabel'),
                      sub: langCtrl.isThai ? 'เงินต้น + ดอกเบี้ย 7 วัน + ค่าดำเนินการ' : 'Principal + 7-Day Interest + Fee',
                      value: CurrencyFormatter.format(_calculationResult.totalAmount),
                      isTotal: true,
                    ),
                    const SizedBox(height: 22),

                    // Apply Button with Confirmation Modal Trigger
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isApplying ? null : _confirmAndApplyLoan,
                        icon: _isApplying
                            ? const SizedBox.shrink()
                            : const Icon(Icons.flash_on_rounded, size: 20),
                        label: _isApplying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : Text(
                                langCtrl.tr('apply7DayLoanBtn'),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            langCtrl.isThai
                                ? 'ผลการคำนวณเป็นการจำลองเพื่อการวางแผนการเงิน ไม่ใช่การกู้ยืมจริง'
                                : 'Simulated calculation for planning only. Not an actual loan.',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required Color color,
    required String label,
    required String sub,
    required String value,
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTotal ? 14 : 13,
                  fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                  color: isTotal ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.w900,
            color: isTotal ? AppColors.secondary : color,
          ),
        ),
      ],
    );
  }
}
