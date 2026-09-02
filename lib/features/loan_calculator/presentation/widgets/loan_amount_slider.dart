import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Interactive slider & preset selector for loan amount (Up to 50,000 THB) with dynamic localization
class LoanAmountSlider extends StatelessWidget {
  final double currentAmount;
  final ValueChanged<double> onChanged;

  const LoanAmountSlider({
    super.key,
    required this.currentAmount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Dynamic Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
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
                    langCtrl.isThai
                        ? 'เลือกตามความสามารถในการชำระหนี้'
                        : 'Choose based on your repayment capability',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showCustomAmountDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(currentAmount, showSymbol: true),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_rounded, size: 14, color: AppColors.primary),
                    ],
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
              overlayColor: AppColors.primary.withValues(alpha: 0.15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
              trackHeight: 6,
            ),
            child: Slider(
              value: currentAmount.clamp(AppConstants.minLoanAmount, AppConstants.maxLoanAmount),
              min: AppConstants.minLoanAmount,
              max: AppConstants.maxLoanAmount,
              divisions: ((AppConstants.maxLoanAmount - AppConstants.minLoanAmount) /
                      AppConstants.loanAmountStep)
                  .toInt(),
              onChanged: (val) {
                onChanged(val.roundToDouble());
              },
            ),
          ),

          // Min & Max Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  langCtrl.isThai ? 'ต่ำสุด ฿1,000' : 'Min ฿1,000',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  langCtrl.isThai ? 'สูงสุด ฿50,000' : 'Max ฿50,000',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Quick Presets
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppConstants.loanAmountPresets.map((preset) {
                final isSelected = (preset == currentAmount);
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
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) {
                        onChanged(preset);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomAmountDialog(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final controller = TextEditingController(text: currentAmount.toInt().toString());

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(langCtrl.isThai ? 'ระบุวงเงินสินเชื่อที่ต้องการ' : 'Specify Loan Amount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              langCtrl.tr('amountRange'),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                prefixText: '฿ ',
                hintText: langCtrl.isThai ? 'เช่น 35000' : 'e.g. 35000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(langCtrl.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                onChanged(val.clamp(AppConstants.minLoanAmount, AppConstants.maxLoanAmount));
              }
              Navigator.of(dialogCtx).pop();
            },
            child: Text(langCtrl.tr('ok')),
          ),
        ],
      ),
    );
  }
}
