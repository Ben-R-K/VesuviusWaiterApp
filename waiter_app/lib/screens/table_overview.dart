import 'package:flutter/material.dart';
import 'package:waiter_app/services/session_manager.dart';
import 'package:waiter_app/models/dto.dart';
import 'package:waiter_app/screens/menu_screen.dart';



class TableOverviewScreen extends StatefulWidget {
  final SessionManager sessionManager;
  const TableOverviewScreen({super.key, required this.sessionManager});

  @override
  State<TableOverviewScreen> createState() => _TableOverviewScreenState();
}

class _TableOverviewScreenState extends State<TableOverviewScreen> {

  void _showAssignDialog(TableDto table) {
    final controller = TextEditingController(text: table.customerName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tildel kunde til bord ${table.name}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Kundens navn'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuller')),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              setState(() {
                tables = tables.map((t) => t.id == table.id ? TableDto(id: t.id, name: t.name, occupied: t.occupied, customerName: name) : t).toList();
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Gem'),
          ),
        ],
      ),
    );
  }
// ...existing code...
  List<TableDto> tables = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.sessionManager.backend.getTables();
      setState(() => tables = list.map((t) => TableDto(
        id: t.id,
        name: t.name,
        occupied: t.occupied,
        customerName: (t as dynamic).customerName ?? null,
      )).toList());
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // (removed duplicate _showAssignDialog)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bordoversigt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTables,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Fejl: $_error'), const SizedBox(height: 8), ElevatedButton(onPressed: _loadTables, child: const Text('Prøv igen'))]))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: tables.length,
                  itemBuilder: (ctx, i) {
                    final t = tables[i];
                    final hasCustomer = t.customerName != null && t.customerName!.isNotEmpty;
                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: hasCustomer
                          ? () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => MenuScreen(
                                  sessionManager: widget.sessionManager,
                                  table: t,
                                ),
                              ));
                            }
                          : () {
                              _showAssignDialog(t);
                            },
                      child: Opacity(
                        opacity: hasCustomer ? 0.6 : 1.0,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          color: Colors.white,
                          shadowColor: Colors.green[200],
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                colors: [Colors.green[100]!, Colors.green[300]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_seat, size: 40, color: Colors.green[800]),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Bord',
                                    style: TextStyle(fontSize: 18, color: Colors.green[900], fontWeight: FontWeight.w500, letterSpacing: 1.2),
                                  ),
                                  Text(
                                    t.name,
                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 2),
                                  ),
                                  if (t.customerName != null && t.customerName!.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Text('Kunde: ${t.customerName}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => MenuScreen(sessionManager: widget.sessionManager),
          ));
        },
        icon: const Icon(Icons.restaurant_menu),
        label: const Text('Menu'),
      ),
    );
  }
}