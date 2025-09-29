import 'package:flutter/material.dart';
import 'package:waiter_app/models/dto.dart';
import 'package:waiter_app/services/session_manager.dart';
import 'package:waiter_app/screens/menu_screen.dart';

class ServeTableScreen extends StatefulWidget {
  final TableDto table;
  final SessionManager sessionManager;
  const ServeTableScreen({super.key, required this.table, required this.sessionManager});

  @override
  State<ServeTableScreen> createState() => _ServeTableScreenState();
}

class _ServeTableScreenState extends State<ServeTableScreen> {
  final TextEditingController _customerController = TextEditingController();
  bool _loading = false;
  String? _error;


  @override
  void initState() {
    super.initState();
    _customerController.text = widget.table.customerName ?? '';
    _loadReservation();
  }

  Future<void> _loadReservation() async {
    // TODO: Integrate with reservation system if needed
    // Example: fetch reservation for this table if exists
  }

  void _proceedToOrder() {
    final name = _customerController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Indtast kundens navn');
      return;
    }
    // Optionally: assign customer to table in backend
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => MenuScreen(sessionManager: widget.sessionManager, table: TableDto(
        id: widget.table.id,
        name: widget.table.name,
        occupied: true,
        customerName: name,
      )),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Betjen bord ${widget.table.name}')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Kunde for bord ${widget.table.name}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            TextField(
              controller: _customerController,
              decoration: const InputDecoration(labelText: 'Kundens navn'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Gå til bestilling'),
              onPressed: _loading ? null : _proceedToOrder,
            ),
          ],
        ),
      ),
    );
  }
}
