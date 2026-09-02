import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../loan_calculator/presentation/controllers/loan_controller.dart';
import '../../../loan_calculator/presentation/screens/loan_calculator_screen.dart';
import '../../../loan_calculator/presentation/screens/saved_loans_screen.dart';
import '../../../loan_calculator/presentation/screens/schedule_and_compare_tab.dart';
import '../../../product_info/presentation/screens/product_info_screen.dart';

/// Main Dashboard container for Finclub Loan Application with dynamic localization
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late final LoanController _loanController;

  @override
  void initState() {
    super.initState();
    _loanController = LoanController();
  }

  @override
  void dispose() {
    _loanController.dispose();
    super.dispose();
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);

    final screens = [
      LoanCalculatorScreen(
        onNavigateToProductInfo: () => _navigateToTab(3),
      ),
      ScheduleAndCompareTab(
        onNavigateToCalculator: () => _navigateToTab(0),
      ),
      SavedLoansScreen(
        onNavigateToCalculator: () => _navigateToTab(1),
      ),
      const ProductInfoScreen(),
    ];

    return LoanControllerProvider(
      controller: _loanController,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _navigateToTab,
            backgroundColor: Colors.white,
            indicatorColor: AppColors.primaryLight.withValues(alpha: 0.15),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.calculate_outlined),
                selectedIcon: const Icon(Icons.calculate_rounded, color: AppColors.primary),
                label: langCtrl.tr('navCalculator'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.table_chart_outlined),
                selectedIcon: const Icon(Icons.table_chart_rounded, color: AppColors.primary),
                label: langCtrl.tr('navSchedule'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.bookmark_outline_rounded),
                selectedIcon: const Icon(Icons.bookmark_rounded, color: AppColors.primary),
                label: langCtrl.tr('navSavedPlans'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.info_outline_rounded),
                selectedIcon: const Icon(Icons.info_rounded, color: AppColors.primary),
                label: langCtrl.tr('navProductInfo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
