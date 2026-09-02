# 🏦 Finclub - Loan Calculator Mobile Application

> **Target Platforms**: Android (Google Play Store) & iOS (Apple App Store)  
> **Framework**: Flutter 3.47+ / Dart 3.13+  
> **Architecture Pattern**: Feature-First Clean Architecture  
> **Primary Purpose**: Production-ready loan calculation and digital loan application simulator.

---

## 📌 1. Product Overview: Finclub Loan Calculator
**สโลแกน**: *"สินเชื่อที่ออกแบบมาเพื่อความต้องการของคุณ"*

- **วงเงินสินเชื่อ**: สูงสุด **50,000 บาท** (1,000 - 50,000 บาท) เลือกวงเงินตามความต้องการและความสามารถในการชำระหนี้
- **อัตราดอกเบี้ย**: สูงสุด **35.80% ต่อปี** อัตราดอกเบี้ยเป็นไปตามหลักเกณฑ์และเงื่อนไขของผลิตภัณฑ์ (รองรับทั้งแบบลดต้นลดดอก Effective Rate และแบบคงที่ Flat Rate)
- **ระยะเวลาผ่อนชำระ**: **3 - 6 เดือน** (เลือกได้ 3, 4, 5, 6 งวด)

---

## 📂 2. Directory Structure & Responsibilities

```text
fintech/
├── lib/
│   ├── app/                                 # App-level orchestration
│   │   ├── app.dart                         # Root MaterialApp widget & global configs
│   │   ├── routes/app_routes.dart           # Route generator
│   │   └── theme/
│   │       ├── app_colors.dart              # Fintech branding colors & gradients
│   │       └── app_theme.dart               # Material 3 design system theme
│   │
│   ├── core/                                # Shared foundations
│   │   ├── constants/app_constants.dart     # Finclub constants & loan thresholds
│   │   ├── utils/currency_formatter.dart    # Currency formatting
│   │   └── widgets/custom_button.dart       # Standardized buttons
│   │
│   └── features/
│       ├── loan_calculator/                 # Core Loan Calculation Feature
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── installment_item.dart
│       │   │   │   ├── loan_calculation_result.dart
│       │   │   │   └── saved_loan_item.dart
│       │   │   └── usecases/calculate_loan.dart   # Reducing balance & Flat rate math
│       │   └── presentation/
│       │       ├── controllers/loan_controller.dart
│       │       ├── screens/
│       │       │   ├── loan_calculator_screen.dart    # Tab 1: Interactive calculator
│       │       │   ├── schedule_and_compare_tab.dart  # Tab 2: Amortization & comparison
│       │       │   ├── saved_loans_screen.dart        # Tab 3: Saved simulations
│       │       │   ├── schedule_detail_screen.dart    # Detailed amortization modal
│       │       │   └── loan_application_flow_screen.dart # 3-Step loan application flow
│       │       └── widgets/
│       │           ├── product_info_banner.dart
│       │           ├── loan_amount_slider.dart
│       │           ├── tenure_selector.dart
│       │           ├── interest_rate_card.dart
│       │           ├── calculation_result_card.dart
│       │           ├── schedule_table_widget.dart
│       │           └── tenure_comparison_card.dart
│       │
│       ├── product_info/                    # Tab 4: Terms, DTI Calculator & FAQ
│       │   └── presentation/screens/product_info_screen.dart
│       │
│       └── dashboard/                       # Root 4-tab navigation shell
│           └── presentation/screens/dashboard_screen.dart
│
└── test/
    ├── loan_calculation_test.dart           # Mathematical precision tests
    └── widget_test.dart                     # UI interaction tests
```

---

## 🚀 3. Quality Verification & Commands

```bash
# Analyze code quality
flutter analyze

# Run unit and widget tests
flutter test
```

