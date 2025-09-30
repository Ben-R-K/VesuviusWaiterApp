import 'package:flutter/material.dart';
import 'package:waiter_app/services/session_manager.dart';

import 'package:waiter_app/models/dto.dart';
import 'package:waiter_app/models/cart.dart';

class OrderScreen extends StatefulWidget {
  final SessionManager sessionManager;
  final TableDto table;
  final TableOrderCart? cart;
  final MenuItemDto? menuItem;
  const OrderScreen({super.key, required this.sessionManager, required this.table, this.cart, this.menuItem});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}


class _OrderScreenState extends State<OrderScreen> {
  bool _loading = false;
  String? _error;
  String? _success;
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();


  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }


  Future<void> _placeOrder() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      final backend = widget.sessionManager.backend;
      if (widget.cart != null) {
        // Cart-based order: group all items
        final items = <String>[];
        for (final cartItem in widget.cart!.items) {
          items.addAll(List<String>.filled(cartItem.quantity, cartItem.menuItem.id));
        }
        await backend.createOrder(
          widget.table.id,
          items,
          tableName: widget.table.name,
          // Optionally, you could concatenate notes from all items
          notes: widget.cart!.items.map((e) => e.notes).where((n) => n != null && n.isNotEmpty).join('; '),
        );
        setState(() => _success = 'Bestilling sendt!');
        widget.cart!.clear();
      } else if (widget.menuItem != null) {
        // Single item order (legacy)
        final items = List<String>.filled(_quantity, widget.menuItem!.id);
        await backend.createOrder(
          widget.table.id,
          items,
          tableName: widget.table.name,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );
        setState(() => _success = 'Bestilling sendt!');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cart != null
            ? 'Bestilling for Bord: ${widget.table.name}'
            : 'Bestil: ${widget.menuItem?.name ?? ''}'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: widget.cart != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Bord: ${widget.table.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          itemCount: widget.cart!.items.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (ctx, i) {
                            final cartItem = widget.cart!.items[i];
                            return ListTile(
                              title: Text(cartItem.menuItem.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              subtitle: cartItem.notes != null && cartItem.notes!.isNotEmpty
                                  ? Text('Noter: ${cartItem.notes}', style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic))
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    onPressed: _loading || cartItem.quantity <= 1
                                        ? null
                                        : () => setState(() => cartItem.quantity--),
                                  ),
                                  Text('${cartItem.quantity}', style: const TextStyle(fontSize: 18)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    onPressed: _loading
                                        ? null
                                        : () => setState(() => cartItem.quantity++),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: _loading
                                        ? null
                                        : () => setState(() => widget.cart!.removeItem(cartItem.menuItem, notes: cartItem.notes)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_loading) const Center(child: CircularProgressIndicator()),
                      if (_error != null) Text('Fejl: $_error', style: const TextStyle(color: Colors.red)),
                      if (_success != null) Text(_success!, style: const TextStyle(color: Colors.green)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _loading || widget.cart!.isEmpty ? null : _placeOrder,
                        label: const Text('Send samlet bestilling'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Bord: ${widget.table.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Text(widget.menuItem?.name ?? '', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      if (widget.menuItem?.description != null && widget.menuItem!.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(widget.menuItem!.description!, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle, size: 32),
                            onPressed: _loading || _quantity <= 1 ? null : () => setState(() => _quantity--),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('$_quantity', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, size: 32),
                            onPressed: _loading ? null : () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _notesController,
                        enabled: !_loading,
                        decoration: InputDecoration(
                          labelText: 'Ændringer / Tilføjelser',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        minLines: 1,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),
                      if (_loading) const Center(child: CircularProgressIndicator()),
                      if (_error != null) Text('Fejl: $_error', style: const TextStyle(color: Colors.red)),
                      if (_success != null) Text(_success!, style: const TextStyle(color: Colors.green)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _loading ? null : _placeOrder,
                        label: const Text('Send bestilling'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
