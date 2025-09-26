import 'dart:async';
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
  List<TableDto> tables = [];
  bool _loading = true;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadTables();
    _pollTimer = Timer.periodic(widget.sessionManager.backendPollInterval, (_) => _loadTables());
  }

  Future<void> _loadTables() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.sessionManager.backend.getTables();
      setState(() => tables = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _openSettings() {
    final baseController = TextEditingController(text: widget.sessionManager.baseUrl);
    final tokenController = TextEditingController(text: widget.sessionManager.token ?? '');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Dev settings'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: baseController, decoration: const InputDecoration(labelText: 'Base URL')),
        TextField(controller: tokenController, decoration: const InputDecoration(labelText: 'Auth token (dev)'), obscureText: false),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        TextButton(onPressed: () {
          final newBase = baseController.text.trim();
          final newToken = tokenController.text.trim();
          if (newBase.isNotEmpty) widget.sessionManager.setBaseUrl(newBase);
          widget.sessionManager.setToken(newToken.isEmpty ? null : newToken);
          Navigator.of(ctx).pop();
          _loadTables();
        }, child: const Text('Apply'))
      ],
    ));
  }

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
          IconButton(icon: const Icon(Icons.settings), onPressed: () => _openSettings()),
          IconButton(icon: const Icon(Icons.logout), onPressed: () {
            widget.sessionManager.logout();
            // Since login screen removed, just clear token and reload tables
            widget.sessionManager.setToken(null);
            _loadTables();
          })
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Fejl: $_error'), const SizedBox(height: 8), ElevatedButton(onPressed: _loadTables, child: const Text('Prøv igen'))]))
              : GridView.count(
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
