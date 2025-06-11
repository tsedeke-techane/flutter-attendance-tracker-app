import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crossplatform_flutter/domain/auth/user.dart';

class TestHelpers {
  static Future<void> loginAsTeacher(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).first, 'teacher_id');
    await tester.enterText(find.byType(TextFormField).last, 'teacher_password');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
  }

  static Future<void> loginAsStudent(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).first, 'student_id');
    await tester.enterText(find.byType(TextFormField).last, 'student_password');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
  }

  static Future<void> waitForLoading(WidgetTester tester) async {
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      await tester.pump();
    }
  }

  static Future<void> verifySnackBar(WidgetTester tester, String message) async {
    expect(find.text(message), findsOneWidget);
    await tester.pumpAndSettle();
  }

  static Future<void> verifyDialog(WidgetTester tester, String title) async {
    expect(find.text(title), findsOneWidget);
    await tester.pumpAndSettle();
  }

  static Future<void> navigateTo(WidgetTester tester, String routeName) async {
    await tester.tap(find.text(routeName));
    await tester.pumpAndSettle();
  }

  static Future<void> enterTextInField(WidgetTester tester, String label, String text) async {
    await tester.enterText(find.widgetWithText(TextFormField, label), text);
    await tester.pumpAndSettle();
  }

  static Future<void> tapButton(WidgetTester tester, String buttonText) async {
    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();
  }

  static Future<void> verifyTextPresent(WidgetTester tester, String text) async {
    expect(find.text(text), findsOneWidget);
  }

  static Future<void> verifyTextNotPresent(WidgetTester tester, String text) async {
    expect(find.text(text), findsNothing);
  }

  static Future<void> verifyWidgetPresent(WidgetTester tester, Type widgetType) async {
    expect(find.byType(widgetType), findsOneWidget);
  }

  static Future<void> verifyWidgetNotPresent(WidgetTester tester, Type widgetType) async {
    expect(find.byType(widgetType), findsNothing);
  }
} 