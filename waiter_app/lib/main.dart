import 'package:flutter/material.dart';
import 'package:waiter_app/screens/login_screen.dart';
import 'package:waiter_app/screens/table_overview.dart';
import 'package:waiter_app/services/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionManager = SessionManager();
  runApp(MyApp(sessionManager: sessionManager));
}

class MyApp extends StatelessWidget {
  final SessionManager sessionManager;
  const MyApp({super.key, required this.sessionManager});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.from(
      colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
    );

    // Attempt to mimic the kitchen app visual style: clean layout, vivid accent.
    return MaterialApp(
      title: 'Vesuvius Waiter App',
      theme: baseTheme.copyWith(
        colorScheme: baseTheme.colorScheme.copyWith(secondary: Colors.deepOrange),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (ctx) => LoginScreen(sessionManager: sessionManager),
        '/tables': (ctx) => TableOverviewScreen(sessionManager: sessionManager),
      },
    );
  }
}
