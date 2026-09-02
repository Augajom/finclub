import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/services/session_service.dart';
import '../widgets/terms_dialog.dart';
import 'pin_lock_screen.dart';
import 'pin_setup_screen.dart';
import 'welcome_auth_screen.dart';

/// Smart Entry Gate checking session, database verification, auto-login, PIN, and biometric security
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndRoute();
  }

  void _checkAuthenticationAndRoute() async {
    // Add small delay for smooth launch transition
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final isLoggedIn = await SessionService.instance.isLoggedIn();
    if (!isLoggedIn) {
      _navigateTo(const WelcomeAuthScreen());
      return;
    }

    // Verify directly with MySQL DB if user still exists in database
    final dbUser = await ApiService.instance.getMe();
    if (!mounted) return;

    if (dbUser == null) {
      // User was deleted from DB or token invalid -> clear session and redirect to WelcomeAuthScreen
      await SessionService.instance.clearSession();
      if (mounted) {
        _navigateTo(const WelcomeAuthScreen());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LanguageProvider.of(context).isThai
                  ? 'ไม่พบบัญชีผู้ใช้ในระบบ หรือบัญชีถูกลบแล้ว กรุณาเข้าสู่ระบบใหม่'
                  : 'User account not found. Please log in again.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final hasAcceptedTerms = await SessionService.instance.hasAcceptedTerms();
    if (!hasAcceptedTerms) {
      if (mounted) {
        TermsDialog.show(context, onAccepted: () {
          _routeAfterTerms(dbUser);
        });
      }
      return;
    }

    _routeAfterTerms(dbUser);
  }

  void _routeAfterTerms(dynamic user) async {
    final hasPin = await SessionService.instance.hasPin();

    if (hasPin) {
      // User has PIN -> Go to PIN Lock / Biometric screen
      _navigateTo(PinLockScreen(user: user));
    } else {
      // User logged in but hasn't set up PIN -> Set up PIN
      _navigateTo(const PinSetupScreen());
    }
  }

  void _navigateTo(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (ctx, anim1, anim2) => screen,
        transitionsBuilder: (ctx, anim1, anim2, child) => FadeTransition(
          opacity: anim1,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
