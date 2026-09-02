import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/auth_gate_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/pin_lock_screen.dart';
import '../../features/auth/presentation/screens/pin_setup_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/welcome_auth_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/product_info/presentation/screens/product_info_screen.dart';

/// Centralized route definitions and route generator for Finclub
class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String pinLock = '/pin-lock';
  static const String pinSetup = '/pin-setup';
  static const String dashboard = '/dashboard';
  static const String productInfo = '/product-info';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return MaterialPageRoute(
          builder: (_) => const AuthGateScreen(),
          settings: settings,
        );
      case welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeAuthScreen(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case pinLock:
        return MaterialPageRoute(
          builder: (_) => const PinLockScreen(),
          settings: settings,
        );
      case pinSetup:
        return MaterialPageRoute(
          builder: (_) => const PinSetupScreen(),
          settings: settings,
        );
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      case productInfo:
        return MaterialPageRoute(
          builder: (_) => const ProductInfoScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
