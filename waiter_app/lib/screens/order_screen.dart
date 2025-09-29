import 'package:flutter/material.dart';
import 'package:waiter_app/services/session_manager.dart';
import 'package:waiter_app/models/dto.dart';



class OrderScreen extends StatefulWidget {
  final SessionManager sessionManager;
  final TableDto table;
  final MenuItemDto menuItem;
  const OrderScreen({super.key, required this.sessionManager, required this.table, required this.menuItem});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _placeOrder() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      final backend = widget.sessionManager.backend;
      // Optionally pass customerId/reservationId if available
      await backend.createOrder(widget.table.id, [widget.menuItem.id]);
      setState(() => _success = 'Bestilling sendt!');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bestil: ${widget.menuItem.name}')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Bord: ${widget.table.name}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Text('Ret: ${widget.menuItem.name}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null) Text('Fejl: $_error', style: const TextStyle(color: Colors.red)),
            if (_success != null) Text(_success!, style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _placeOrder,
              child: const Text('Send bestilling'),
            ),
          ],
        ),
      ),
    );
  }
}
