import 'package:flutter/material.dart';
import 'package:waiter_app/services/session_manager.dart';
import 'package:waiter_app/services/reservation_manager.dart';
import 'package:waiter_app/models/dto.dart';
import 'package:waiter_app/screens/menu_screen.dart';
import 'package:waiter_app/screens/finished_orders_screen.dart';
import 'package:waiter_app/screens/table_assignment_screen.dart';
import 'package:waiter_app/screens/simple_test_screen.dart';
import 'package:waiter_app/screens/reservations_screen.dart';



class TableOverviewScreen extends StatefulWidget {
  final SessionManager sessionManager;
  const TableOverviewScreen({super.key, required this.sessionManager});

  @override
  State<TableOverviewScreen> createState() => _TableOverviewScreenState();
}

class _TableOverviewScreenState extends State<TableOverviewScreen> {

  List<TableDto> tables = [];
  List<Map<String, dynamic>> reservations = [];
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
      // Load tables
      final list = await widget.sessionManager.backend.getTables();
      
      // Get current reservations from the reservation manager
      final reservationManager = ReservationManager();
      final currentReservations = reservationManager.getAllReservations();
      
      setState(() {
        tables = list.map((t) {
          // Check if this table has a current reservation
          Map<String, dynamic>? reservation;
          try {
            reservation = currentReservations.firstWhere(
              (res) {
                final tableNumbers = List<int>.from(res['tableNumbers']);
                return tableNumbers.contains(int.parse(t.name));
              },
            );
          } catch (e) {
            reservation = null; // No reservation found
          }
          
          if (reservation != null) {
            return TableDto(
              id: t.id,
              name: t.name,
              occupied: true,
              customerName: reservation['customerName'] as String?,
              reservationTime: reservation['time'] as String?,
            );
          } else {
            return TableDto(
              id: t.id,
              name: t.name,
              occupied: t.occupied,
              customerName: (t as dynamic).customerName ?? null,
            );
          }
        }).toList();
        
        reservations = currentReservations.map((r) => {
          'tableNumbers': r['tableNumbers'],
          'time': r['time'],
          'customerName': r['customerName'],
          'partySize': r['partySize'],
        }).toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _showReservationOptionsDialog(BuildContext context, TableDto table) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bord ${table.name} - Reserveret'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (table.customerName != null) 
                Text('Kunde: ${table.customerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (table.reservationTime != null)
                Text('Tid: ${table.reservationTime}'),
              const SizedBox(height: 16),
              const Text('Hvad vil du gøre?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuller'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Go to menu for taking order
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MenuScreen(
                    sessionManager: widget.sessionManager,
                    table: table,
                  ),
                ));
              },
              child: const Text('Tag bestilling'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Go to table assignment to modify reservation
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TableAssignmentScreen(sessionManager: widget.sessionManager),
                ));
                _loadTables();
              },
              child: const Text('Ændre reservation'),
            ),
          ],
        );
      },
    );
  }

  // (removed duplicate _showAssignDialog)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bordoversigt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note),
            tooltip: 'Se reservationer',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ReservationsScreen(sessionManager: widget.sessionManager),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_business),
            tooltip: 'Tildel nyt bord',
            onPressed: () async {
              print('Table assignment button pressed'); // Debug
              try {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TableAssignmentScreen(sessionManager: widget.sessionManager),
                ));
                // Refresh the table overview after returning from table assignment
                _loadTables();
              } catch (e) {
                print('Error navigating to table assignment: $e');
                // Fallback to simple test screen
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SimpleTestScreen(sessionManager: widget.sessionManager),
                ));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.assignment_turned_in),
            tooltip: 'Færdige ordrer',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FinishedOrdersScreen(sessionManager: widget.sessionManager),
              ));
            },
          ),
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
                    crossAxisCount: 2, // 2 tables per row
                    childAspectRatio: 1.0, // Square cards
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: tables.length,
                  itemBuilder: (ctx, i) {
                    final t = tables[i];
                    final hasCustomer = t.customerName != null && t.customerName!.isNotEmpty;
                    final isReserved = t.reservationTime != null && t.reservationTime!.isNotEmpty;
                    
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        if (isReserved) {
                          // Show reservation options dialog for reserved tables
                          await _showReservationOptionsDialog(context, t);
                        } else if (hasCustomer) {
                          // Go to menu for occupied tables
                          print('Navigating to menu for table ${t.name}'); // Debug
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => MenuScreen(
                              sessionManager: widget.sessionManager,
                              table: t,
                            ),
                          ));
                        } else {
                          // Go to table assignment for empty tables
                          print('Navigating to table assignment from empty table ${t.name}'); // Debug
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => TableAssignmentScreen(sessionManager: widget.sessionManager),
                          ));
                          // Refresh after returning from table assignment
                          _loadTables();
                        }
                      },
                      child: Opacity(
                        opacity: hasCustomer ? 0.8 : 1.0,
                        child: Card(
                          elevation: hasCustomer ? 2 : 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: Colors.white,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: isReserved 
                                  ? [Colors.purple[100]!, Colors.purple[300]!] // Purple for reservations
                                  : hasCustomer 
                                    ? [Colors.orange[100]!, Colors.orange[300]!] // Orange for walk-ins
                                    : [Colors.green[100]!, Colors.green[300]!], // Green for available
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isReserved ? Icons.event_seat : hasCustomer ? Icons.person : Icons.event_seat, 
                                    size: 28, 
                                    color: isReserved ? Colors.purple[800] : hasCustomer ? Colors.orange[800] : Colors.green[800]
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    t.name,
                                    style: const TextStyle(
                                      fontSize: 20, 
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.black87
                                    ),
                                  ),
                                  if (isReserved) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Reserveret', 
                                      style: TextStyle(
                                        fontSize: 12, 
                                        color: Colors.purple[700],
                                        fontWeight: FontWeight.w500,
                                      )
                                    ),
                                    Text(
                                      'kl. ${t.reservationTime}', 
                                      style: TextStyle(
                                        fontSize: 10, 
                                        color: Colors.purple[600],
                                      )
                                    ),
                                  ] else if (hasCustomer) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Optaget', 
                                      style: TextStyle(
                                        fontSize: 12, 
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.w500,
                                      )
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ledig', 
                                      style: TextStyle(
                                        fontSize: 12, 
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      )
                                    ),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FinishedOrdersScreen(sessionManager: widget.sessionManager),
              ));
            },
            icon: const Icon(Icons.assignment_turned_in),
            label: const Text('Færdige Ordrer'),
            heroTag: "finished_orders",
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MenuScreen(sessionManager: widget.sessionManager),
              ));
            },
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Menu'),
            heroTag: "menu",
          ),
        ],
      ),
    );
  }
}