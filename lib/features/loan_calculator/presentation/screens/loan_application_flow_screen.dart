import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Simulated loan application and eligibility pre-check flow for Finclub 7-Day Loan with dynamic localization
class LoanApplicationFlowScreen extends StatefulWidget {
  final double loanAmount;
  final int tenureDays;
  final double interestPerDay;
  final double revenueFee;
  final double totalAmount;

  const LoanApplicationFlowScreen({
    super.key,
    required this.loanAmount,
    this.tenureDays = 7,
    double? interestPerDay,
    double? revenueFee,
    double? totalAmount,
  })  : interestPerDay = interestPerDay ?? ((loanAmount * 0.358) / 365),
        revenueFee = revenueFee ?? (loanAmount * 0.01 > 50 ? loanAmount * 0.01 : 50.0),
        totalAmount = totalAmount ??
            (loanAmount + (((loanAmount * 0.358) / 365) * 7) + (loanAmount * 0.01 > 50 ? loanAmount * 0.01 : 50.0));

  @override
  State<LoanApplicationFlowScreen> createState() => _LoanApplicationFlowScreenState();
}

class _LoanApplicationFlowScreenState extends State<LoanApplicationFlowScreen> {
  int _currentStep = 0;
  final _fullNameController = TextEditingController(text: 'สมชาย ใจดี');
  final _phoneController = TextEditingController(text: '081-234-5678');
  final _incomeController = TextEditingController(text: '25000');
  String _selectedOccupation = 'employee';
  bool _isProcessing = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _submitApplication() async {
    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _currentStep = 2; // Step 3 result
    });
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langCtrl.isThai ? 'จำลองการประเมินสินเชื่อ 7 วัน' : '7-Day Loan Pre-Check Simulator'),
      ),
      body: Column(
        children: [
          // Step Progress Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                _buildStepCircle(0, langCtrl.isThai ? 'วงเงิน' : 'Amount'),
                _buildStepDivider(0),
                _buildStepCircle(1, langCtrl.isThai ? 'ข้อมูล' : 'Details'),
                _buildStepDivider(1),
                _buildStepCircle(2, langCtrl.isThai ? 'ผลจำลอง' : 'Simulation'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStepContent(langCtrl),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(langCtrl),
    );
  }

  Widget _buildStepCircle(int stepIndex, String title) {
    final isDone = _currentStep > stepIndex;
    final isCurrent = _currentStep == stepIndex;

    Color circleColor;
    if (isDone) {
      circleColor = AppColors.success;
    } else if (isCurrent) {
      circleColor = AppColors.primary;
    } else {
      circleColor = AppColors.border;
    }

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: (isCurrent || isDone) ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int afterStepIndex) {
    final isDone = _currentStep > afterStepIndex;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
        color: isDone ? AppColors.success : AppColors.border,
      ),
    );
  }

  Widget _buildCurrentStepContent(LanguageController langCtrl) {
    switch (_currentStep) {
      case 0:
        return _buildStep1LoanReview(langCtrl);
      case 1:
        return _buildStep2ApplicantInfo(langCtrl);
      case 2:
      default:
        return _buildStep3ApprovalResult(langCtrl);
    }
  }

  Widget _buildStep1LoanReview(LanguageController langCtrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          langCtrl.isThai ? 'ตรวจสอบรายการจำลองสินเชื่อ 7 วันที่เลือก' : 'Review Selected 7-Day Simulation',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          langCtrl.isThai
              ? 'จำลองการคำนวณและประเมินภาระดอกเบี้ยเบื้องต้น เพื่อการวางแผนทางการเงิน'
              : 'Simulate interest and evaluate debt capacity for financial planning',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(langCtrl.tr('principalLabel'), style: const TextStyle(color: Colors.white70)),
                  Text(
                    CurrencyFormatter.format(widget.loanAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(langCtrl.tr('tenure'), style: const TextStyle(color: Colors.white70)),
                  Text(
                    langCtrl.tr('tenureFixedDays'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(langCtrl.tr('dailyInterestLabel'), style: const TextStyle(color: Colors.white70)),
                  Text(
                    '${CurrencyFormatter.format(widget.interestPerDay)} ${langCtrl.tr('perDay')} (35.80% p.a.)',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(langCtrl.tr('revenueFeeLabel'), style: const TextStyle(color: Colors.white70)),
                  Text(
                    CurrencyFormatter.format(widget.revenueFee),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(langCtrl.tr('totalRepaymentLabel'), style: const TextStyle(color: Colors.white70)),
                  Text(
                    CurrencyFormatter.format(widget.totalAmount),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Features Checklist
        _buildBenefitRow(Icons.calculate_rounded, langCtrl.isThai ? 'คำนวณภาระหนี้ DTI และดอกเบี้ยอัตโนมัติ' : 'Automated DTI and daily interest calculation'),
        _buildBenefitRow(Icons.insights_rounded, langCtrl.isThai ? 'เพื่อการวางแผนการเงินส่วนบุคคลเบื้องต้น' : 'For personal financial planning and simulation'),
        _buildBenefitRow(Icons.shield_rounded, langCtrl.isThai ? 'ไม่มีการตรวจเครดิตบูโรหรือทำสัญญาผูกมัดจริง' : 'No credit bureau check or contractual obligation'),
      ],
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.success, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2ApplicantInfo(LanguageController langCtrl) {
    final occupationMap = {
      'employee': langCtrl.isThai ? 'พนักงานประจำ / ข้าราชการ' : 'Full-time Employee / Civil Servant',
      'business': langCtrl.isThai ? 'เจ้าของธุรกิจ / ผู้ประกอบการ' : 'Business Owner / Entrepreneur',
      'freelance': langCtrl.isThai ? 'อาชีพอิสระ / ฟรีแลนซ์' : 'Freelancer / Self-Employed',
      'daily': langCtrl.isThai ? 'พนักงานรับจ้างรายวัน / รายสัปดาห์' : 'Daily / Weekly Wage Earner',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          langCtrl.isThai ? 'ข้อมูลผู้สมัครเบื้องต้น' : 'Applicant Basic Information',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          langCtrl.isThai
              ? 'กรอกข้อมูลเพื่อจำลองการประเมินความสามารถในการชำระหนี้ (DTI)'
              : 'Enter details to simulate debt repayment ability (DTI)',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        Text(
          langCtrl.isThai ? 'ชื่อ-นามสกุล (ผู้ใช้งานจำลอง)' : 'Full Name (Simulated User)',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _fullNameController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person_outline_rounded),
            hintText: langCtrl.isThai ? 'ระบุชื่อและนามสกุล' : 'Enter your full name',
          ),
        ),
        const SizedBox(height: 16),

        Text(
          langCtrl.isThai ? 'เบอร์โทรศัพท์มือถือ' : 'Mobile Phone Number',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.phone_iphone_rounded),
            hintText: '08X-XXX-XXXX',
          ),
        ),
        const SizedBox(height: 16),

        Text(
          langCtrl.isThai ? 'อาชีพปัจจุบัน' : 'Current Occupation',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedOccupation,
          items: occupationMap.entries.map((e) {
            return DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 13)));
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedOccupation = val);
            }
          },
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.work_outline_rounded),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          langCtrl.isThai ? 'รายได้รวมต่อเดือน (บาท)' : 'Monthly Income (THB)',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _incomeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.monetization_on_outlined),
            prefixText: '฿ ',
            hintText: langCtrl.isThai ? 'เช่น 25000' : 'e.g. 25000',
          ),
        ),
      ],
    );
  }

  Widget _buildStep3ApprovalResult(LanguageController langCtrl) {
    final income = double.tryParse(_incomeController.text) ?? 20000.0;
    final dtiRatio = (widget.totalAmount / income) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 50),
        ),
        const SizedBox(height: 16),
        Text(
          langCtrl.isThai ? 'ผลการจำลองการประเมินเบื้องต้น!' : 'Simulation Pre-Check Passed!',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          langCtrl.isThai
              ? 'คุณ${_fullNameController.text} มีความสามารถในการชำระหนี้อยู่ในเกณฑ์ปลอดภัยสำหรับการจำลองวงเงินนี้'
              : 'Congratulations ${_fullNameController.text}, your debt capacity is within safe parameters for this simulation',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // Pre-Approval Certificate Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.success, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(langCtrl.isThai ? 'วงเงินจำลองที่ประเมิน' : 'Simulated Limit', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('SIMULATION RESULT (7 DAYS)', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(widget.loanAmount),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const Divider(height: 20, color: AppColors.divider),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(langCtrl.isThai ? 'ระยะเวลารอบจำลอง' : 'Simulation Tenure', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text(
                    langCtrl.tr('tenureFixedDays'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(langCtrl.tr('totalRepaymentLabel'), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text(
                    CurrencyFormatter.format(widget.totalAmount),
                    style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(langCtrl.isThai ? 'สัดส่วนภาระหนี้ต่อรายได้ (DTI)' : 'Debt-to-Income (DTI)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text(
                    '${dtiRatio.toStringAsFixed(1)}% (${langCtrl.isThai ? 'เกณฑ์ปลอดภัย' : 'Safe'})',
                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warningLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  langCtrl.isThai
                      ? 'หมายเหตุ: ผลลัพธ์นี้เป็นเพียงการจำลองการคำนวณเบื้องต้นเพื่อการวางแผนทางการเงินเท่านั้น แอปพลิเคชัน Finclub ไม่มีบริการปล่อยสินเชื่อหรือโอนเงินกู้จริงแต่อย่างใด'
                      : 'Notice: This is an estimated simulation result for financial planning purposes only. Finclub does not offer, broker, or disburse actual loans.',
                  style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _buildBottomBar(LanguageController langCtrl) {
    if (_currentStep == 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(langCtrl.isThai ? 'เสร็จสิ้นและกลับหน้าคำนวณ' : 'Finish & Back to Calculator'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _currentStep--);
                },
                child: Text(langCtrl.tr('back')),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () {
                      if (_currentStep == 0) {
                        setState(() => _currentStep = 1);
                      } else if (_currentStep == 1) {
                        _submitApplication();
                      }
                    },
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _currentStep == 0
                          ? (langCtrl.isThai ? 'ถัดไป: กรอกข้อมูลจำลอง' : 'Next: Enter Details')
                          : (langCtrl.isThai ? 'ดูผลการจำลอง' : 'View Simulation Result'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
