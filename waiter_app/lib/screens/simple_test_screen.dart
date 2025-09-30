import 'package:flutter/material.dart';
import 'package:waiter_app/services/session_manager.dart';

class SimpleTestScreen extends StatelessWidget {
  final SessionManager sessionManager;
  
  const SimpleTestScreen({super.key, required this.sessionManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Screen'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Navigation Works!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Table assignment screen is accessible',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}