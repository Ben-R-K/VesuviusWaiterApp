import 'package:flutter/material.dart';
import 'package:waiter_app/screens/menu_screen.dart';
import 'package:waiter_app/services/session_manager.dart';

class TableOverviewScreen extends StatelessWidget {
  final SessionManager sessionManager;
  const TableOverviewScreen({super.key, required this.sessionManager});

  @override
  Widget build(BuildContext context) {
    return MenuScreen(sessionManager: sessionManager);
  }
}
