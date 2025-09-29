import 'package:flutter/material.dart';
import 'package:waiter_app/screens/menu_screen.dart';
import 'package:waiter_app/services/session_manager.dart';

class OrderScreen extends StatelessWidget {
  final SessionManager sessionManager;
  const OrderScreen({super.key, required this.sessionManager, required table});

  @override
  Widget build(BuildContext context) {
    return MenuScreen(sessionManager: sessionManager);
  }
}
