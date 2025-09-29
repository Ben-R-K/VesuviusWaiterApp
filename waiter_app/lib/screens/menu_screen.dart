import 'package:flutter/material.dart';
import 'package:waiter_app/services/session_manager.dart';
import 'package:waiter_app/models/dto.dart';
import 'package:waiter_app/models/cart.dart';
import 'order_screen.dart';

class MenuScreen extends StatefulWidget {
  final SessionManager sessionManager;
  final TableDto? table;
  const MenuScreen({super.key, required this.sessionManager, this.table});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItemDto> menu = [];
  bool _loading = true;
  String? _error;
  TableOrderCart? cart;

  @override
  void initState() {
    super.initState();
    _loadMenu();
    if (widget.table != null) {
      cart = TableOrderCart(widget.table!);
    }
  }

  Future<void> _loadMenu() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await widget.sessionManager.backend.getMenu();
      setState(() {
        menu = items;
      });
    } catch (e) {
      setState(() {
        _error = 'Kunne ikke hente menuen. Prøv igen.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.table != null ? 'Menu for Bord ${widget.table!.name}' : 'Menu'),
        actions: widget.table != null && cart != null
            ? [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'Se bestilling',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => OrderScreen(
                        sessionManager: widget.sessionManager,
                        table: widget.table!,
                        cart: cart,
                      ),
                    ));
                  },
                )
              ]
            : [],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: menu.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final m = menu[i];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        title: Text(
                          m.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.visible,
                          softWrap: true,
                        ),
                        subtitle: m.description != null && m.description!.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
                                child: Text(
                                  m.description!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                    height: 1.35,
                                    letterSpacing: 0.1,
                                  ),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                ),
                              )
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${m.price.toStringAsFixed(0)} kr',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
                              ),
                            ),
                            if (widget.table != null && cart != null)
                              IconButton(
                                icon: const Icon(Icons.add),
                                tooltip: 'Tilføj til bestilling',
                                onPressed: () async {
                                  final result = await showDialog<_CartAddResult>(
                                    context: context,
                                    builder: (context) => _AddToCartDialog(menuItem: m),
                                  );
                                  if (result != null && result.quantity > 0) {
                                    setState(() {
                                      cart!.addItem(m, quantity: result.quantity, notes: result.notes);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Tilføjet til bestilling: ${m.name} x${result.quantity}')),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                        onTap: null,
                      ),
                    );
                  },
                ),
    );
  }
}

class _CartAddResult {
  final int quantity;
  final String? notes;
  _CartAddResult(this.quantity, this.notes);
}

class _AddToCartDialog extends StatefulWidget {
  final MenuItemDto menuItem;
  const _AddToCartDialog({required this.menuItem});

  @override
  State<_AddToCartDialog> createState() => _AddToCartDialogState();
}

class _AddToCartDialogState extends State<_AddToCartDialog> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tilføj til bestilling'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.menuItem.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              Text('$_quantity', style: const TextStyle(fontSize: 18)),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Kommentar (f.eks. ingen løg)',
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuller'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_CartAddResult(_quantity, _notesController.text.trim()));
          },
          child: const Text('Tilføj'),
        ),
      ],
    );
  }
}




