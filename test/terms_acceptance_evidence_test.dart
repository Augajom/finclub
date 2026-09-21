import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fintech/core/localization/language_controller.dart';
import 'package:fintech/core/network/api_service.dart';
import 'package:fintech/core/services/session_service.dart';
import 'package:fintech/features/auth/domain/entities/user_entity.dart';
import 'package:fintech/features/auth/presentation/controllers/auth_controller.dart';
import 'package:fintech/features/auth/presentation/widgets/terms_dialog.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ApiService.useLocalMockForTesting = true;
    await SessionService.instance.saveSession(
      token: 'mock_jwt_token',
      user: const UserEntity(
        id: 101,
        email: 'tester@finclub.com',
        hasAcceptedTerms: false,
      ),
    );
  });

  group('Terms Acceptance and Screenshot Evidence Tests', () {
    test('acceptTerms updates local session and user entity correctly', () async {
      expect(await SessionService.instance.hasAcceptedTerms(), isFalse);

      final dummyPngBytes = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13]);
      final updatedUser = await ApiService.instance.acceptTerms(imageBytes: dummyPngBytes);

      expect(updatedUser.hasAcceptedTerms, isTrue);
      expect(await SessionService.instance.hasAcceptedTerms(), isTrue);
    });

    testWidgets('TermsDialog displays audit notice and checkbox interacts properly',
        (WidgetTester tester) async {
      bool acceptedCallbackCalled = false;
      final langCtrl = LanguageController();
      final authCtrl = AuthController();

      tester.view.physicalSize = const Size(414 * 2.5, 896 * 2.5);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        LanguageProvider(
          controller: langCtrl,
          child: AuthProvider(
            controller: authCtrl,
            child: MaterialApp(
              home: Scaffold(
                body: TermsDialog(
                  onAccepted: () {
                    acceptedCallbackCalled = true;
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Terms title & audit trail notice are visible
      expect(find.text('ข้อกำหนดและเงื่อนไขการใช้บริการ'), findsOneWidget);
      expect(
        find.text('ระบบจะบันทึกภาพหน้าจอและข้อมูลอิเล็กทรอนิกส์ไว้เป็นหลักฐานการยินยอม'),
        findsOneWidget,
      );

      // Verify accept button is initially disabled before checking checkbox
      final acceptBtn = find.widgetWithText(ElevatedButton, 'ยอมรับข้อตกลงและเข้าสู่ระบบ');
      expect(acceptBtn, findsOneWidget);

      final ElevatedButton initialButton = tester.widget(acceptBtn);
      expect(initialButton.onPressed, isNull);

      // Check the checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      final ElevatedButton enabledButton = tester.widget(acceptBtn);
      expect(enabledButton.onPressed, isNotNull);

      // Tap accept button
      await tester.tap(acceptBtn);
      await tester.pumpAndSettle();

      expect(acceptedCallbackCalled, isTrue);
      expect(await SessionService.instance.hasAcceptedTerms(), isTrue);
    });
  });
}
