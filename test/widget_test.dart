import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fintech/app/app.dart';
import 'package:fintech/core/network/api_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ApiService.useLocalMockForTesting = true;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/local_auth'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isDeviceSupported') {
          return false;
        }
        if (methodCall.method == 'canCheckBiometrics') {
          return false;
        }
        if (methodCall.method == 'getAvailableBiometrics') {
          return <String>[];
        }
        return false;
      },
    );
  });

  testWidgets('Full User Journey: AuthGate -> Login -> Terms -> PIN Setup -> 7-Day Loan Calculator',
      (WidgetTester tester) async {
    // Set standard mobile device resolution
    tester.view.physicalSize = const Size(414 * 2.5, 896 * 2.5);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FintechApp());
    await tester.pumpAndSettle();

    // 1. App starts via AuthGate into Welcome / Auth Choice Screen
    expect(find.text('Finclub'), findsWidgets);
    expect(find.text('สมัครสมาชิก'), findsOneWidget);
    expect(find.text('เข้าสู่ระบบ'), findsOneWidget);

    // Tap "เข้าสู่ระบบ"
    await tester.ensureVisible(find.text('เข้าสู่ระบบ'));
    await tester.tap(find.text('เข้าสู่ระบบ'));
    await tester.pumpAndSettle();

    // 2. Login Screen
    expect(find.text('เข้าสู่ระบบสมาชิก'), findsWidgets);
    expect(find.text('อีเมล (Email)'), findsOneWidget);
    expect(find.text('รหัสผ่าน (Password)'), findsOneWidget);

    // Enter email and password
    await tester.enterText(find.byType(TextFormField).first, 'user@finclub.com');
    await tester.enterText(find.byType(TextFormField).last, 'Password@123');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'เข้าสู่ระบบ'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'เข้าสู่ระบบ'));
    await tester.pumpAndSettle();

    // 3. Terms and Conditions Dialog shown on first entry
    expect(find.text('ข้อกำหนดและเงื่อนไขการใช้บริการ'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);

    // Tick checkbox and accept terms
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ยอมรับข้อตกลงและเข้าสู่ระบบ'));
    await tester.pumpAndSettle();

    // 4. PIN Setup Screen
    expect(find.text('ตั้งรหัส PIN 6 หลัก'), findsWidgets);

    // Enter 6-digit PIN: 1, 2, 3, 4, 5, 6
    for (final digit in ['1', '2', '3', '4', '5', '6']) {
      await tester.tap(find.byKey(Key('keypad_$digit')));
      await tester.pump(const Duration(milliseconds: 50));
    }
    // Wait for the transition to confirm step
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Confirm step
    expect(find.text('ยืนยันรหัส PIN 6 หลัก'), findsWidgets);
    for (final digit in ['1', '2', '3', '4', '5', '6']) {
      await tester.tap(find.byKey(Key('keypad_$digit')));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();

    // If Biometrics dialog appears, skip
    if (find.text('ข้ามไปก่อน').evaluate().isNotEmpty) {
      await tester.tap(find.text('ข้ามไปก่อน'));
      await tester.pumpAndSettle();
    }

    // 5. Main 7-Day Fixed Loan Calculator Screen
    expect(find.text('Finclub'), findsWidgets);
    expect(find.text('รอบคำนวณ 7 วัน'), findsOneWidget);

    // Verify 4 required metrics are displayed:
    expect(find.text('วงเงินที่คำนวณ'), findsWidgets);
    expect(find.text('ดอกเบี้ยต่อวัน'), findsWidgets);
    expect(find.text('ค่าดำเนินการประมาณการ'), findsWidgets);
    expect(find.text('ยอด Total รวมประมาณการ'), findsWidgets);

    // Verify Apply button
    expect(find.text('จำลองผลการประเมินสินเชื่อ'), findsOneWidget);
  });
}
