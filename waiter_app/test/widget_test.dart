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
import 'package:waiter_app/screens/table_overview.dart';

void main() {
  testWidgets('TableOverviewScreen vises korrekt', (WidgetTester tester) async {
    final sessionManager = SessionManager();
    await tester.pumpWidget(MyApp(sessionManager: sessionManager));

    // Tjek at TableOverviewScreen vises
    expect(find.byType(TableOverviewScreen), findsOneWidget);
  });
}
