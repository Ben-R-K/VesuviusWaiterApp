import 'package:flutter/material.dart';
import 'package:waiter_app/services/session_manager.dart';
import 'package:waiter_app/models/dto.dart';

class FinishedOrdersScreen extends StatefulWidget {
  final SessionManager sessionManager;
  const FinishedOrdersScreen({super.key, required this.sessionManager});

  @override
  State<FinishedOrdersScreen> createState() => _FinishedOrdersScreenState();
}

class _FinishedOrdersScreenState extends State<FinishedOrdersScreen> {
  List<OrderDto> orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFinishedOrders();
  }

  Future<void> _loadFinishedOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {

      final allOrders = await widget.sessionManager.backend.getOrders();
      setState(() {
        orders = allOrders.where((order) => order.status == 'READY').toList();
      });
    } catch (e) {
      setState(() {
        _error = 'Kunne ikke hente færdige ordrer: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _completeOrder(OrderDto order) async {
    try {
      await widget.sessionManager.backend.updateOrderStatus(order.id, 'COMPLETED');

      setState(() {
        orders.removeWhere((o) => o.id == order.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ordre for Bord ${order.tableNumber ?? 'Ukendt'} blev afsluttet')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl ved afslutning af ordre: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Færdige Ordrer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFinishedOrders,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFinishedOrders,
                        child: const Text('Prøv igen'),
                      ),
                    ],
                  ),
                )
              : orders.isEmpty
                  ? const Center(
                      child: Text(
                        'Ingen færdige ordrer',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Bord ${order.tableNumber ?? 'Ukendt'}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'FÆRDIG',
                                        style: TextStyle(
                                          color: Colors.green[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (order.items != null && order.items!.isNotEmpty) ...[
                                  const Text(
                                    'Indhold:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...order.items!.map((item) => Padding(
                                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                                        child: Text(
                                          '• ${item.quantity ?? 1}x ${item.name ?? 'Ukendt vare'}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      )),
                                ],
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _completeOrder(order),
                                    icon: const Icon(Icons.check_circle),
                                    label: const Text('Afslut Ordre'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}