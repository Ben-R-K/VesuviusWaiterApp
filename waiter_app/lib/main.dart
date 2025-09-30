import 'package:flutter/material.dart';
import 'package:waiter_app/screens/table_overview.dart';
import 'package:waiter_app/services/session_manager.dart';
import 'package:waiter_app/theme/app_theme.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Replace 'DEV_TOKEN' with a real token for connecting to your authenticated backend.
  HttpOverrides.global = MyHttpOverrides();
  final sessionManager = SessionManager(autoLoginToken: 'DEV_TOKEN');
  await sessionManager.detectAndSetWorkingBaseUrl();
  runApp(MyApp(sessionManager: sessionManager));
}



class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
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
