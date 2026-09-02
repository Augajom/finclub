import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../widgets/balance_card.dart';

/// Fintech Home / Dashboard overview screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
              child: const Icon(Icons.person_outline, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Badge(
              smallSize: 8,
              backgroundColor: AppColors.error,
              child: Icon(Icons.notifications_none_rounded),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BalanceCard(
              totalBalance: 128450.75,
              monthlyIncome: 65000.00,
              monthlyExpense: 23450.25,
            ),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 28),
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.send_rounded, 'label': 'Transfer', 'color': AppColors.primaryLight},
      {'icon': Icons.qr_code_scanner_rounded, 'label': 'Scan & Pay', 'color': AppColors.secondary},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Top-up', 'color': AppColors.accent},
      {'icon': Icons.receipt_long_rounded, 'label': 'Bills', 'color': Colors.purple},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((item) {
        final icon = item['icon'] as IconData;
        final label = item['label'] as String;
        final color = item['color'] as Color;

        return Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = [
      {
        'title': 'Salary Deposit',
        'category': 'Income',
        'date': 'Today, 09:30 AM',
        'amount': 65000.00,
        'isIncome': true,
        'icon': Icons.work_outline_rounded,
      },
      {
        'title': 'Coffee & Bistro',
        'category': 'Food & Drinks',
        'date': 'Yesterday, 02:15 PM',
        'amount': -145.00,
        'isIncome': false,
        'icon': Icons.coffee_rounded,
      },
      {
        'title': 'Internet Subscription',
        'category': 'Utilities',
        'date': '22 Aug 2026',
        'amount': -799.00,
        'isIncome': false,
        'icon': Icons.wifi_rounded,
      },
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const Divider(height: 16, color: AppColors.divider),
          itemBuilder: (context, index) {
            final tx = transactions[index];
            final isIncome = tx['isIncome'] as bool;
            final amount = tx['amount'] as double;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isIncome
                      ? AppColors.income.withValues(alpha: 0.1)
                      : AppColors.expense.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tx['icon'] as IconData,
                  color: isIncome ? AppColors.income : AppColors.expense,
                ),
              ),
              title: Text(
                tx['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Text(
                '${tx['category']} • ${tx['date']}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: Text(
                '${isIncome ? '+' : ''}${CurrencyFormatter.format(amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isIncome ? AppColors.income : AppColors.textPrimary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
