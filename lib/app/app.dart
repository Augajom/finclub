import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/language_controller.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

/// Root application widget for Finclub
class FintechApp extends StatefulWidget {
  const FintechApp({super.key});

  @override
  State<FintechApp> createState() => _FintechAppState();
}

class _FintechAppState extends State<FintechApp> {
  late final LanguageController _languageController;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _languageController = LanguageController();
    _authController = AuthController();
  }

  @override
  void dispose() {
    _languageController.dispose();
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LanguageProvider(
      controller: _languageController,
      child: AuthProvider(
        controller: _authController,
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.initial,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }
}

