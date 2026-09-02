import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../loan_calculator/domain/entities/seven_day_loan_result.dart';

/// Comprehensive product details, eligibility requirements, 7-day loan terms & FAQs with dynamic localization
class ProductInfoScreen extends StatefulWidget {
  const ProductInfoScreen({super.key});

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  // DTI Calculator state
  final _salaryController = TextEditingController(text: '25000');
  final _existingDebtController = TextEditingController(text: '3000');
  double _calculatedMaxPayment = 7000.0;
  double _currentDti = 12.0;

  @override
  void initState() {
    super.initState();
    _recalculateDti();
  }

  void _recalculateDti() {
    final salary = double.tryParse(_salaryController.text) ?? 0.0;
    final debt = double.tryParse(_existingDebtController.text) ?? 0.0;

    if (salary > 0) {
      final maxTotalDebt = salary * 0.40;
      final availableForLoan = (maxTotalDebt - debt).clamp(0.0, salary * 0.40);
      setState(() {
        _calculatedMaxPayment = availableForLoan;
        _currentDti = (debt / salary) * 100;
      });
    }
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _existingDebtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langCtrl.tr('productInfoTitle')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Title Card
            _buildHeroProductCard(langCtrl),
            const SizedBox(height: 20),

            // 3 Core Criteria Cards
            Text(
              langCtrl.tr('productHighlightTitle'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            _buildHighlightsList(langCtrl),
            const SizedBox(height: 24),

            // 7-Day Sample Calculation Table
            _buildSampleCalculationSection(langCtrl),
            const SizedBox(height: 24),

            // Eligibility & Requirements
            _buildEligibilitySection(langCtrl),
            const SizedBox(height: 24),

            // DTI Calculator
            _buildDtiCalculatorCard(langCtrl),
            const SizedBox(height: 24),

            // Frequently Asked Questions (FAQ)
            _buildFaqSection(langCtrl),
            const SizedBox(height: 24),

            // Customer Support Contact
            _buildSupportSection(langCtrl),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroProductCard(LanguageController langCtrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
            ),
            child: const Text(
              'Finclub',
              style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            langCtrl.tr('tagline'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            langCtrl.tr('productHighlightDesc'),
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsList(LanguageController langCtrl) {
    final items = [
      {
        'icon': Icons.account_balance_wallet_rounded,
        'title': langCtrl.tr('featureLoanAmountTitle'),
        'desc': langCtrl.tr('maxAmount'),
        'sub': langCtrl.tr('featureLoanAmountDesc'),
        'color': AppColors.primaryLight,
      },
      {
        'icon': Icons.percent_rounded,
        'title': langCtrl.tr('featureInterestRateTitle'),
        'desc': langCtrl.tr('maxRatePerYear'),
        'sub': langCtrl.tr('featureInterestRateDesc'),
        'color': AppColors.interestColor,
      },
      {
        'icon': Icons.timer_outlined,
        'title': langCtrl.tr('featureTenureTitle'),
        'desc': langCtrl.tr('tenureFixedDays'),
        'sub': langCtrl.tr('featureTenureDesc'),
        'color': AppColors.secondary,
      },
    ];

    return Column(
      children: items.map((item) {
        final icon = item['icon'] as IconData;
        final title = item['title'] as String;
        final desc = item['desc'] as String;
        final sub = item['sub'] as String;
        final color = item['color'] as Color;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            desc,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sub,
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSampleCalculationSection(LanguageController langCtrl) {
    final sampleAmounts = [10000.0, 20000.0, 50000.0];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  langCtrl.isThai
                      ? 'ตัวอย่างการคำนวณสินเชื่อ 7 วัน (35.80% ต่อปี)'
                      : '7-Day Loan Calculation Examples (35.80% p.a.)',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sampleAmounts.map((amount) {
            final res = SevenDayLoanResult.compute(principal: amount, annualRate: 35.80);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${langCtrl.tr('principalLabel')} ${CurrencyFormatter.format(res.principal)}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${langCtrl.tr('dailyInterestLabel')} ${CurrencyFormatter.format(res.interestPerDay)} ${langCtrl.tr('perDay')} • ${langCtrl.tr('revenueFeeLabel')} ${CurrencyFormatter.format(res.revenueFee)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        langCtrl.tr('totalRepaymentLabel'),
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        CurrencyFormatter.format(res.totalAmount),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.secondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEligibilitySection(LanguageController langCtrl) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  langCtrl.isThai
                      ? 'คุณสมบัติและเอกสารประกอบการสมัคร'
                      : 'Applicant Qualifications & Required Documents',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildCheckItem(langCtrl.tr('qualAge')),
          _buildCheckItem(langCtrl.tr('qualIncome')),
          _buildCheckItem(langCtrl.tr('qualAccount')),
          _buildCheckItem('${langCtrl.tr('docIdCard')}, ${langCtrl.tr('docBankStatement')}'),
          _buildCheckItem(langCtrl.isThai
              ? 'ไม่ต้องใช้บุคคลหรือหลักทรัพย์ในการค้ำประกัน'
              : 'No guarantor or collateral required'),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDtiCalculatorCard(LanguageController langCtrl) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calculate_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      langCtrl.isThai
                          ? 'ประเมินความสามารถในการผ่อน (DTI Tool)'
                          : 'Debt Affordability Assessment (DTI Tool)',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      langCtrl.isThai
                          ? 'คำนวณยอดชำระที่ปลอดภัยต่อรายได้'
                          : 'Estimate safe monthly debt repayment',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      langCtrl.isThai ? 'รายได้ต่อเดือน' : 'Monthly Income',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(prefixText: '฿ ', isDense: true),
                      onChanged: (_) => _recalculateDti(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      langCtrl.isThai ? 'ภาระหนี้เดิมต่อเดือน' : 'Existing Monthly Debt',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _existingDebtController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(prefixText: '฿ ', isDense: true),
                      onChanged: (_) => _recalculateDti(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        langCtrl.isThai ? 'ยอดหนี้สูงสุดที่แนะนำ' : 'Max Recommended Repayment',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        CurrencyFormatter.format(_calculatedMaxPayment),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _currentDti <= 40 ? AppColors.successLight : AppColors.accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DTI ${_currentDti.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _currentDti <= 40 ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(LanguageController langCtrl) {
    final faqs = [
      {
        'q': langCtrl.tr('faq1Q'),
        'a': langCtrl.tr('faq1A'),
      },
      {
        'q': langCtrl.tr('faq2Q'),
        'a': langCtrl.tr('faq2A'),
      },
      {
        'q': langCtrl.tr('faq3Q'),
        'a': langCtrl.tr('faq3A'),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          langCtrl.tr('faqTitle'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        ...faqs.map((faq) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(
                  faq['q']!,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                      faq['a']!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildSupportSection(LanguageController langCtrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.support_agent_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langCtrl.isThai ? 'ศูนย์บริการลูกค้า Finclub' : 'Finclub Customer Support',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  langCtrl.isThai
                      ? 'โทร: 02-123-4567 • ทุกวัน 08:30 - 18:00 น.'
                      : 'Tel: 02-123-4567 • Mon - Sun 08:30 - 18:00',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
