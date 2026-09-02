import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../controllers/auth_controller.dart';
import '../widgets/terms_dialog.dart';
import '../../../../core/services/session_service.dart';
import 'pin_setup_screen.dart';
import 'register_screen.dart';

/// Screen for Member Login with email and password (Vertically and Horizontally Centered)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final langCtrl = LanguageProvider.of(context);

    if (_formKey.currentState?.validate() ?? false) {
      final authCtrl = AuthController.of(context);
      final success = await authCtrl.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        void routeNext() async {
          final hasPin = await SessionService.instance.hasPin();
          if (!mounted) return;
          if (!hasPin) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const PinSetupScreen()),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
            );
          }
        }

        if (!authCtrl.hasAcceptedTerms) {
          TermsDialog.show(context, onAccepted: routeNext);
        } else {
          routeNext();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authCtrl.errorMessage ?? (langCtrl.isThai ? 'เข้าสู่ระบบล้มเหลว' : 'Login failed')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final authCtrl = AuthController.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langCtrl.tr('loginTitle')),
        actions: [
          IconButton(
            onPressed: () {
              final newLang = langCtrl.isThai ? 'en' : 'th';
              langCtrl.setLanguage(newLang);
            },
            icon: Text(
              langCtrl.isThai ? '🇹🇭' : '🇬🇧',
              style: const TextStyle(fontSize: 18),
            ),
            tooltip: langCtrl.tr('switchLanguage'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Icon / Header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        langCtrl.tr('loginTitle'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        langCtrl.tr('loginSubtitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Email Field
                    Text(langCtrl.tr('emailLabel'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: langCtrl.tr('emailHint'),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return langCtrl.isThai ? 'กรุณากรอกอีเมล' : 'Please enter email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Password Field
                    Text(langCtrl.tr('passwordLabel'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: langCtrl.tr('passwordHint'),
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return langCtrl.isThai ? 'กรุณากรอกรหัสผ่าน' : 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authCtrl.isLoading ? null : _onLogin,
                        child: authCtrl.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : Text(
                                langCtrl.tr('loginBtn'),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Switch to Register
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: Text(langCtrl.tr('dontHaveAccount')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
