// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waiter_app/main.dart';
import 'package:waiter_app/services/session_manager.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final sessionManager = SessionManager();
    await tester.pumpWidget(MyApp(sessionManager: sessionManager));

    // Verify that the login screen is shown
    expect(find.text('Tjener Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
