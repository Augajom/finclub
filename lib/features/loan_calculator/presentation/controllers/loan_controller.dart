import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../domain/entities/loan_calculation_result.dart';
import '../../domain/entities/saved_loan_item.dart';
import '../../domain/entities/seven_day_loan_result.dart';
import '../../domain/usecases/calculate_loan.dart';

/// State management controller for Finclub loan calculator & user-isolated saved plans
class LoanController extends ChangeNotifier {
  final CalculateLoanUseCase _calculator;

  double _loanAmount = AppConstants.defaultLoanAmount;
  double _interestRate = AppConstants.defaultInterestRate;
  int _tenureMonths = AppConstants.defaultTenureMonths;
  bool _isReducingBalance = true;
  bool _isLoadingPlans = false;

  late LoanCalculationResult _result;
  late SevenDayLoanResult _sevenDayResult;
  final List<SavedLoanItem> _savedLoans = [];

  LoanController({CalculateLoanUseCase? calculator})
      : _calculator = calculator ?? const CalculateLoanUseCase() {
    _recalculate();
    fetchSavedPlans();
  }

  // Getters
  double get loanAmount => _loanAmount;
  double get interestRate => _interestRate;
  int get tenureMonths => _tenureMonths;
  bool get isReducingBalance => _isReducingBalance;
  bool get isLoadingPlans => _isLoadingPlans;
  LoanCalculationResult get result => _result;
  SevenDayLoanResult get sevenDayResult => _sevenDayResult;
  List<SavedLoanItem> get savedLoans => List.unmodifiable(_savedLoans);

  void _recalculate() {
    _result = _calculator.execute(
      loanAmount: _loanAmount,
      annualInterestRate: _interestRate,
      tenureMonths: _tenureMonths,
      isReducingBalance: _isReducingBalance,
    );
    _sevenDayResult = SevenDayLoanResult.compute(
      principal: _loanAmount,
      annualRate: _interestRate,
    );
    notifyListeners();
  }

  void setLoanAmount(double amount) {
    final clamped = amount.clamp(AppConstants.minLoanAmount, AppConstants.maxLoanAmount);
    if (_loanAmount != clamped) {
      _loanAmount = clamped;
      _recalculate();
    }
  }

  void setInterestRate(double rate) {
    final clamped = rate.clamp(AppConstants.minInterestRate, AppConstants.maxInterestRate);
    if (_interestRate != clamped) {
      _interestRate = clamped;
      _recalculate();
    }
  }

  void setTenureMonths(int months) {
    if (AppConstants.availableTenures.contains(months) && _tenureMonths != months) {
      _tenureMonths = months;
      _recalculate();
    }
  }

  void setIsReducingBalance(bool value) {
    if (_isReducingBalance != value) {
      _isReducingBalance = value;
      _recalculate();
    }
  }

  /// Calculates comparison for available tenures
  Map<int, LoanCalculationResult> getComparisonResults() {
    final Map<int, LoanCalculationResult> comparisons = {};
    for (final tenure in AppConstants.availableTenures) {
      comparisons[tenure] = _calculator.execute(
        loanAmount: _loanAmount,
        annualInterestRate: _interestRate,
        tenureMonths: tenure,
        isReducingBalance: _isReducingBalance,
      );
    }
    return comparisons;
  }

  /// Fetches real saved plans from MySQL database for the authenticated user
  Future<void> fetchSavedPlans() async {
    _isLoadingPlans = true;
    notifyListeners();

    try {
      final plans = await ApiService.instance.getSavedPlans();
      _savedLoans.clear();
      _savedLoans.addAll(plans);
    } catch (e) {
      debugPrint('[LoanController] Error fetching saved plans: $e');
    } finally {
      _isLoadingPlans = false;
      notifyListeners();
    }
  }

  /// Saves the 7-day loan plan into MySQL database for this user
  Future<SavedLoanItem> save7DayLoanPlan({
    SevenDayLoanResult? result,
    String? customTitle,
    String? note,
  }) async {
    final target = result ?? _sevenDayResult;
    final title = customTitle ?? 'สินเชื่อ 7 วัน ฿${target.principal.toInt()}';

    // 1. Call real backend API
    final savedFromApi = await ApiService.instance.createSavedPlan(
      title: title,
      loanAmount: target.principal,
      annualRate: target.annualInterestRate,
      note: note,
    );

    final item = savedFromApi ??
        SavedLoanItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          createdAt: DateTime.now(),
          loanAmount: target.principal,
          interestPerDay: target.interestPerDay,
          totalInterest: target.totalInterest,
          revenueFee: target.revenueFee,
          totalAmount: target.totalAmount,
          tenureDays: target.tenureDays,
          dueDate: target.dueDate,
          annualInterestRate: target.annualInterestRate,
          note: note,
        );

    // Update local state list
    _savedLoans.removeWhere((p) => p.id == item.id);
    _savedLoans.insert(0, item);
    notifyListeners();
    return item;
  }

  /// Deletes a saved plan from MySQL database
  Future<void> deleteSavedPlan(String id) async {
    _savedLoans.removeWhere((item) => item.id == id);
    notifyListeners();

    try {
      await ApiService.instance.deleteSavedPlan(id);
    } catch (e) {
      debugPrint('[LoanController] Error deleting plan: $e');
    }
  }

  void loadSavedPlan(SavedLoanItem item) {
    _loanAmount = item.loanAmount;
    _interestRate = item.annualInterestRate;
    _recalculate();
  }
}

/// Global inherited controller provider for simple dependency injection
class LoanControllerProvider extends InheritedNotifier<LoanController> {
  const LoanControllerProvider({
    super.key,
    required LoanController controller,
    required super.child,
  }) : super(notifier: controller);

  static LoanController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<LoanControllerProvider>();
    assert(provider != null, 'No LoanControllerProvider found in context');
    return provider!.notifier!;
  }
}
