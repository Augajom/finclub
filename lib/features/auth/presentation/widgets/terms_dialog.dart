import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/language_controller.dart';
import '../controllers/auth_controller.dart';

/// Modal dialog showing Terms and Conditions upon first login/registration
class TermsDialog extends StatefulWidget {
  final VoidCallback onAccepted;

  const TermsDialog({
    super.key,
    required this.onAccepted,
  });

  static Future<void> show(BuildContext context, {required VoidCallback onAccepted}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: TermsDialog(onAccepted: onAccepted),
      ),
    );
  }

  @override
  State<TermsDialog> createState() => _TermsDialogState();
}

class _TermsDialogState extends State<TermsDialog> {
  bool _isAgreed = false;
  bool _isSubmitting = false;

  void _onAccept() async {
    if (!_isAgreed) return;

    setState(() => _isSubmitting = true);
    final authCtrl = AuthController.of(context);
    await authCtrl.acceptTerms();

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.of(context).pop();
    widget.onAccepted();
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 580),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.gavel_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        langCtrl.tr('termsTitle'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        langCtrl.tr('termsSubtitle'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),

            // Scrollable Terms Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        langCtrl.isThai
                            ? 'ข้อกำหนดและเงื่อนไขการใช้บริการ ${AppConstants.appName}'
                            : '${AppConstants.appName} Terms & Conditions',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      _buildTermParagraph(
                        langCtrl.isThai ? '1. วัตถุประสงค์และการให้บริการ' : '1. Purpose & Service Scope',
                        langCtrl.isThai
                            ? 'Finclub ให้บริการระบบคำนวณและยื่นขอสินเชื่อระยะสั้น 7 วัน เพื่อเสริมสภาพคล่องทางการเงิน ภายใต้ข้อกำหนดและกฎหมายที่เกี่ยวข้อง'
                            : 'Finclub provides a calculation and application platform for short-term 7-day micro loans to assist with liquidity under applicable laws.',
                      ),
                      _buildTermParagraph(
                        langCtrl.isThai ? '2. การคิดอัตราดอกเบี้ยและค่าธรรมเนียม' : '2. Interest Rates & Fees',
                        langCtrl.isThai
                            ? 'อัตราดอกเบี้ยคำนวณรายวันตามอัตราสูงสุดไม่เกิน 35.80% ต่อปี พร้อมแสดงค่าธรรมเนียมบริการและยอดชำระรวมอย่างโปร่งใส'
                            : 'Interest is calculated on a daily basis capped at 35.80% p.a., with fully transparent service fees and total repayment amounts.',
                      ),
                      _buildTermParagraph(
                        langCtrl.isThai ? '3. การชำระคืนเงินกู้' : '3. Loan Repayment',
                        langCtrl.isThai
                            ? 'ผู้กู้ตกลงชำระคืนเงินต้นพร้อมดอกเบี้ยและค่าธรรมเนียมภายในกำหนดเวลา 7 วันนับจากวันที่ได้รับอนุมัติเงินกู้'
                            : 'Borrower agrees to repay principal, accrued interest, and fees in full within 7 days from the approval date.',
                      ),
                      _buildTermParagraph(
                        langCtrl.isThai ? '4. การคุ้มครองข้อมูลส่วนบุคคล (PDPA)' : '4. Privacy & Data Protection (PDPA)',
                        langCtrl.isThai
                            ? 'Finclub จะเก็บรักษาข้อมูลส่วนบุคคล ข้อมูลอีเมล และภาพถ่ายโปรไฟล์ของผู้ใช้งานด้วยระบบความปลอดภัยมาตรฐาน และไม่เปิดเผยต่อบุคคลภายนอกโดยไม่ได้รับความยินยอม'
                            : 'Finclub safeguards user emails and profile data with industry standards and will not disclose them to third parties without consent.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Agreement Checkbox
            InkWell(
              onTap: () {
                setState(() {
                  _isAgreed = !_isAgreed;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _isAgreed,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _isAgreed = val ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        langCtrl.tr('termsCheckbox'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _isAgreed ? FontWeight.w700 : FontWeight.w500,
                          color: _isAgreed ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Accept Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isAgreed && !_isSubmitting ? _onAccept : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        langCtrl.tr('termsAcceptBtn'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermParagraph(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(content, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
        ],
      ),
    );
  }
}
