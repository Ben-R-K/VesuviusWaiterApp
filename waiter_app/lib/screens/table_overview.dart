import 'package:flutter/material.dart';
import 'package:waiter_app/services/session_manager.dart';
import 'package:waiter_app/models/dto.dart';
import 'package:waiter_app/screens/order_screen.dart';

class TableOverviewScreen extends StatefulWidget {
  final SessionManager sessionManager;
  const TableOverviewScreen({super.key, required this.sessionManager});

  @override
  State<TableOverviewScreen> createState() => _TableOverviewScreenState();
}

class _TableOverviewScreenState extends State<TableOverviewScreen> {
  List<TableDto> tables = List.generate(8, (i) => TableDto(id: i + 1, name: 'Table ${i + 1}', occupied: i % 3 == 0));

  void _openTable(TableDto t) {
    // For now show a simple dialog; real implementation would open order screen.
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderScreen(sessionManager: widget.sessionManager, table: t)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bordoversigt'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () {
            widget.sessionManager.logout();
            Navigator.of(context).pushReplacementNamed('/');
          })
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(12),
        crossAxisCount: 2,
        childAspectRatio: 3,
        children: tables.map((t) => Card(
          color: t.occupied ? Colors.red[200] : Colors.green[200],
          child: InkWell(
            onTap: () => _openTable(t),
            child: Center(child: Text(t.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ),
        )).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
