import 'dart:async';
import 'package:flutter/material.dart';
import 'package:waiter_app/services/session_manager.dart';
import 'package:waiter_app/models/dto.dart';

class MenuScreen extends StatefulWidget {
  final SessionManager sessionManager;
  const MenuScreen({super.key, required this.sessionManager});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItemDto> menu = [];
  bool _loading = true;
  String? _error;
  Timer? _pollTimer;
  List<Map<String, dynamic>> _probeResults = [];


  @override
  void initState() {
    super.initState();
    _loadMenu();
    _pollTimer = Timer.periodic(widget.sessionManager.backendPollInterval, (_) => _loadMenu());
    _runProbes();
  }

  Widget _buildProbeList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Probe results:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ..._probeResults.map((r) {
            final ok = r['ok'] as bool? ?? false;
            final base = r['base'] as String? ?? '';
            final err = r['error'] as String?;
            return ListTile(
              dense: true,
              title: Text(base, style: TextStyle(color: ok ? Colors.green : Colors.red)),
              subtitle: err != null ? Text(err, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
              trailing: ok
                  ? ElevatedButton(onPressed: () {
                      widget.sessionManager.setBaseUrl(base);
                      _loadMenu();
                    }, child: const Text('Use'))
                  : TextButton(onPressed: () {}, child: const Text('')),
            );
          }).toList(),
          Row(children: [
            ElevatedButton(onPressed: _runProbes, child: const Text('Retry probes')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () { widget.sessionManager.setBaseUrl('http://localhost:3000'); _loadMenu(); }, child: const Text('Use localhost')),
          ])
        ]),
      ),
    );
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
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _runProbes() async {
    setState(() {
      _probeResults = [];
      _error = null;
    });
    final results = await widget.sessionManager.detectAndSetWorkingBaseUrl();
    setState(() {
      _probeResults = results;
    });
    // If a working baseUrl was found, reload menu
    if (results.any((r) => r['ok'] == true)) {
      await _loadMenu();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
        
          IconButton(icon: const Icon(Icons.settings), onPressed: () => _openSettings()),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Fejl: $_error'), const SizedBox(height: 8), ElevatedButton(onPressed: _loadMenu, child: const Text('Prøv igen'))]))
              : Column(children: [
                  if (_probeResults.isNotEmpty) Padding(padding: const EdgeInsets.all(8.0), child: _buildProbeList()),
                  Expanded(child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: menu.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final m = menu[i];
                    return ListTile(
                      leading: m.image != null && m.image!.isNotEmpty
                          ? Image.network(m.image!, width: 56, height: 56, fit: BoxFit.cover)
                          : CircleAvatar(child: Text(m.name.isNotEmpty ? m.name[0] : '?')),
                      title: Text(m.name),
                      subtitle: m.description != null ? Text(m.description!) : null,
                      trailing: Text('${m.price.toStringAsFixed(0)} kr'),
                    );
                  },
                  )),
                ]),
    );
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
          _loadMenu();
        }, child: const Text('Apply'))
      ],
    ));
  }
}
