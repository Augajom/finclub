import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/screens/pin_setup_screen.dart';
import '../../../auth/presentation/screens/welcome_auth_screen.dart';
import '../widgets/product_info_banner.dart';
import '../widgets/seven_day_calculator_widget.dart';

/// Main Loan Calculator Screen with 7-Day Fixed Term and Member Profile Header
class LoanCalculatorScreen extends StatelessWidget {
  final VoidCallback? onNavigateToProductInfo;

  const LoanCalculatorScreen({
    super.key,
    this.onNavigateToProductInfo,
  });

  void _showSecurityModal(BuildContext context) async {
    final langCtrl = LanguageProvider.of(context);
    final canBio = await BiometricService.instance.canCheckBiometrics() ||
        await BiometricService.instance.isDeviceSupported();
    bool isBioEnabled = await SessionService.instance.isBiometricEnabled();
    final hasPin = await SessionService.instance.hasPin();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      langCtrl.tr('securityTitle'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(modalCtx).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // PIN Setting Tile
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.pin_rounded, color: AppColors.primary),
                  ),
                  title: Text(
                    hasPin ? langCtrl.tr('changePin') : langCtrl.tr('setPin'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    hasPin ? langCtrl.tr('changePinSubtitle') : langCtrl.tr('setPinSubtitle'),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(modalCtx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PinSetupScreen()),
                    );
                  },
                ),

                const Divider(height: 16),

                // Biometrics Switch Tile
                if (canBio)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.fingerprint_rounded, color: AppColors.secondary),
                    ),
                    title: Text(langCtrl.tr('biometricTitle'), style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(langCtrl.tr('biometricSubtitle')),
                    value: isBioEnabled,
                    activeThumbColor: AppColors.secondary,
                    onChanged: (val) async {
                      await SessionService.instance.setBiometricEnabled(val);
                      setModalState(() {
                        isBioEnabled = val;
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val ? langCtrl.tr('biometricEnabledToast') : langCtrl.tr('biometricDisabledToast')),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onLogout(BuildContext context) async {
    final langCtrl = LanguageProvider.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          langCtrl.tr('logout'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Text(
          langCtrl.tr('logoutConfirm'),
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      langCtrl.tr('cancel'),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      langCtrl.tr('logout'),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authCtrl = AuthController.of(context);
      await authCtrl.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeAuthScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final authCtrl = AuthController.of(context);
    final user = authCtrl.currentUser;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: ClipOval(
                child: user?.formattedAvatarUrl != null && user!.formattedAvatarUrl!.isNotEmpty
                    ? Image.network(
                        user.formattedAvatarUrl!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      )
                    : const Icon(Icons.person_rounded, color: AppColors.primary, size: 18),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    user?.email ?? 'member@finclub.com',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Security / PIN / Biometrics Setting
          IconButton(
            onPressed: () => _showSecurityModal(context),
            icon: const Icon(Icons.security_rounded, color: AppColors.primary, size: 20),
            tooltip: langCtrl.tr('securityTitle'),
            visualDensity: VisualDensity.compact,
          ),
          // Language Switcher
          IconButton(
            onPressed: () {
              final newLang = langCtrl.isThai ? 'en' : 'th';
              langCtrl.setLanguage(newLang);
            },
            icon: Text(
              langCtrl.isThai ? '🇹🇭' : '🇬🇧',
              style: const TextStyle(fontSize: 16),
            ),
            tooltip: langCtrl.tr('switchLanguage'),
            visualDensity: VisualDensity.compact,
          ),
          // Logout
          IconButton(
            onPressed: () => _onLogout(context),
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 20),
            tooltip: langCtrl.tr('logout'),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Highlight Banner (Product specifications)
            ProductInfoBanner(
              onDetailsTap: onNavigateToProductInfo,
            ),
            const SizedBox(height: 18),

            // 2. Fixed 7-Day Loan Calculator
            const SevenDayCalculatorWidget(),
            const SizedBox(height: 20),

            // 3. Trust & Information Footer
            _buildTrustFooter(langCtrl),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustFooter(LanguageController langCtrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  langCtrl.tr('trustFooterTitle'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            langCtrl.tr('trustFooterDesc'),
            style: const TextStyle(
              fontSize: 11,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
