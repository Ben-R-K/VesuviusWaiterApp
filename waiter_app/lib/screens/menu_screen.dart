import 'package:flutter/material.dart';
import 'package:waiter_app/services/session_manager.dart';


import 'package:waiter_app/models/dto.dart';
import 'order_screen.dart';

class MenuScreen extends StatefulWidget {
  final SessionManager sessionManager;
  final TableDto? table;
  const MenuScreen({super.key, required this.sessionManager, this.table});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItemDto> menu = [];
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
        actions: [],
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
                        trailing: Container(
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
                        onTap: widget.table != null
                            ? () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => OrderScreen(
                                    sessionManager: widget.sessionManager,
                                    table: widget.table!,
                                    menuItem: m,
                                  ),
                                ));
                              }
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
  }



