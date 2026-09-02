import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../controllers/auth_controller.dart';
import '../widgets/terms_dialog.dart';
import '../../../../core/services/session_service.dart';
import 'pin_setup_screen.dart';
import 'login_screen.dart';

/// Screen for Member Registration with profile upload and strict password criteria (Centered layout)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRePassword = true;

  Uint8List? _avatarBytes;
  String? _avatarPath;
  String? _avatarName;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  // Password rules validation
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _hasSpecial => RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\\/\[\]~`]').hasMatch(_passwordController.text);
  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _isPasswordValid => _hasUppercase && _hasLowercase && _hasNumber && _hasSpecial && _hasMinLength;

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _avatarBytes = bytes;
          _avatarPath = picked.path;
          _avatarName = picked.name;
        });
      }
    } catch (e) {
      if (mounted) {
        final langCtrl = LanguageProvider.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              langCtrl.isThai ? 'ไม่สามารถเลือกรูปภาพได้: $e' : 'Could not select image: $e',
            ),
          ),
        );
      }
    }
  }

  void _showImagePickerModal() {
    final langCtrl = LanguageProvider.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                langCtrl.tr('uploadAvatar'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.infoLight,
                  child: Icon(Icons.photo_library_rounded, color: AppColors.primary),
                ),
                title: Text(langCtrl.tr('chooseFromGallery')),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.successLight,
                  child: Icon(Icons.camera_alt_rounded, color: AppColors.success),
                ),
                title: Text(langCtrl.tr('takePhoto')),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAvatar(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() async {
    final langCtrl = LanguageProvider.of(context);

    if (!_isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langCtrl.isThai
              ? 'กรุณาตั้งรหัสผ่านให้ถูกต้องตามเงื่อนไขความปลอดภัย'
              : 'Please satisfy all password security requirements'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_passwordController.text != _rePasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langCtrl.tr('passwordsNotMatch')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final authCtrl = AuthController.of(context);
      final success = await authCtrl.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rePassword: _rePasswordController.text,
        imageBytes: _avatarBytes,
        imagePath: _avatarPath,
        imageName: _avatarName,
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
            content: Text(authCtrl.errorMessage ?? (langCtrl.isThai ? 'การสมัครสมาชิกล้มเหลว' : 'Registration failed')),
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
        title: Text(langCtrl.tr('registerTitle')),
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
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        langCtrl.tr('registerTitle'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        langCtrl.tr('registerSubtitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profile Avatar Upload Centerpiece
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  border: Border.all(color: AppColors.primary, width: 2),
                                  image: _avatarBytes != null
                                      ? DecorationImage(
                                          image: MemoryImage(_avatarBytes!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _avatarBytes == null
                                    ? const Icon(Icons.person, size: 48, color: AppColors.primary)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _showImagePickerModal,
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: _showImagePickerModal,
                            icon: const Icon(Icons.upload_file, size: 16),
                            label: Text(
                              _avatarBytes == null ? langCtrl.tr('uploadAvatar') : langCtrl.tr('changeAvatar'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

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
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(val.trim())) {
                          return langCtrl.isThai ? 'รูปแบบอีเมลไม่ถูกต้อง' : 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    Text(langCtrl.tr('passwordLabel'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: langCtrl.tr('passwordHint'),
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Real-time Password Rules Checklist
                    _buildPasswordRulesBox(langCtrl),
                    const SizedBox(height: 16),

                    // Re-password Field
                    Text(langCtrl.tr('rePasswordLabel'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _rePasswordController,
                      obscureText: _obscureRePassword,
                      decoration: InputDecoration(
                        hintText: langCtrl.tr('rePasswordHint'),
                        prefixIcon: const Icon(Icons.lock_reset_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureRePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureRePassword = !_obscureRePassword),
                        ),
                      ),
                      validator: (val) {
                        if (val != _passwordController.text) {
                          return langCtrl.tr('passwordsNotMatch');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authCtrl.isLoading ? null : _onSubmit,
                        child: authCtrl.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : Text(
                                langCtrl.tr('registerBtn'),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Switch to Login
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: Text(langCtrl.tr('alreadyHaveAccount')),
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

  Widget _buildPasswordRulesBox(LanguageController langCtrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            langCtrl.tr('passwordRulesTitle'),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          _buildRuleCheckItem(langCtrl.tr('ruleUppercase'), _hasUppercase),
          _buildRuleCheckItem(langCtrl.tr('ruleLowercase'), _hasLowercase),
          _buildRuleCheckItem(langCtrl.tr('ruleNumber'), _hasNumber),
          _buildRuleCheckItem(langCtrl.tr('ruleSpecial'), _hasSpecial),
          _buildRuleCheckItem(langCtrl.tr('ruleLength'), _hasMinLength),
        ],
      ),
    );
  }

  Widget _buildRuleCheckItem(String label, bool isSatisfied) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(
            isSatisfied ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 14,
            color: isSatisfied ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSatisfied ? FontWeight.w600 : FontWeight.w400,
              color: isSatisfied ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
