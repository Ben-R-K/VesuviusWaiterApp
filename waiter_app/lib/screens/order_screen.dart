import 'package:flutter/material.dart';
import 'package:waiter_app/services/session_manager.dart';
import 'package:waiter_app/models/dto.dart';

class OrderScreen extends StatefulWidget {
  final SessionManager sessionManager;
  final TableDto table;
  const OrderScreen({super.key, required this.sessionManager, required this.table});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<MenuItemDto> menu = [];
  final Set<int> _selected = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.sessionManager.backend.getMenu();
      setState(() => menu = list);
    } catch (e) {
      // fallback mock data
      setState(() {
        _error = 'Kunne ikke hente menukort; bruger lokalt mock';
        menu = List.generate(6, (i) => MenuItemDto(id: i + 1, name: 'Ret ${i + 1}', category: 'Hoved', price: 79.0 + i));
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_selected.isEmpty) return;
    setState(() => _loading = true);
    try {
      final order = await widget.sessionManager.backend.createOrder(widget.table.id, _selected.toList());
      // show confirmation
      await showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Bestilt'), content: Text('Ordre #${order.id} oprettet.'), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))]));
      Navigator.of(context).pop();
    } catch (e) {
      await showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Fejl'), content: Text(e.toString()), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))]));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bestil til ${widget.table.name}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_error != null) Padding(padding: const EdgeInsets.all(8.0), child: Text(_error!, style: const TextStyle(color: Colors.orange))),
                Expanded(
                  child: ListView.builder(
                    itemCount: menu.length,
                    itemBuilder: (ctx, i) {
                      final m = menu[i];
                      final selected = _selected.contains(m.id);
                      return ListTile(
                        title: Text(m.name),
                        subtitle: Text('${m.category} • ${m.price.toStringAsFixed(2)} kr'),
                        trailing: Checkbox(value: selected, onChanged: (v) {
                          setState(() {
                            if (v == true) _selected.add(m.id); else _selected.remove(m.id);
                          });
                        }),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(onPressed: _loading ? null : _placeOrder, icon: const Icon(Icons.send), label: const Text('Send ordre')),
                )
              ],
            ),
    );
  }
}
   