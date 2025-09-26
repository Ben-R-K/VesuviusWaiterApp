import 'package:flutter/material.dart';
import 'package:waiter_app/screens/table_overview.dart';
import 'package:waiter_app/services/session_manager.dart';
import 'package:waiter_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Replace 'DEV_TOKEN' with a real token for connecting to your authenticated backend.
  final sessionManager = SessionManager(autoLoginToken: 'DEV_TOKEN');
  runApp(MyApp(sessionManager: sessionManager));
}

class MyApp extends StatelessWidget {
  final SessionManager sessionManager;
  const MyApp({super.key, required this.sessionManager});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vesuvius Waiter App',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: TableOverviewScreen(sessionManager: sessionManager),
    );
  }
}
