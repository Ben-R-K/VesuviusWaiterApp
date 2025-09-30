import 'package:flutter/material.dart';
import 'package:waiter_app/services/session_manager.dart';
import 'package:waiter_app/services/reservation_manager.dart';
import 'package:waiter_app/screens/menu_screen.dart';

class ReservationsScreen extends StatefulWidget {
  final SessionManager sessionManager;
  
  const ReservationsScreen({super.key, required this.sessionManager});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<Map<String, dynamic>> _reservations = [];
  bool _loading = true;
  String? _error;
  late ReservationManager _reservationManager;

  @override
  void initState() {
    super.initState();
    _reservationManager = ReservationManager();
    _reservationManager.initializeSampleData(); // Initialize with sample data
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Get today's date
      final today = DateTime.now();
      final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      // Get reservations from the reservation manager
      final reservations = _reservationManager.getReservationsForDate(dateStr);

      setState(() {
        _reservations = reservations;
      });

    } catch (e) {
      setState(() {
        _error = 'Kunne ikke indlæse reservationer: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _takeOrder(Map<String, dynamic> reservation) {
    // Navigate to menu for this reservation
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MenuScreen(
        sessionManager: widget.sessionManager,
        // Pass reservation info as a mock table
        table: null, // We'll handle this in the menu screen
        reservationInfo: reservation,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dagens Reservationer'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReservations,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Fejl: $_error'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadReservations,
                        child: const Text('Prøv igen'),
                      ),
                    ],
                  ),
                )
              : _reservations.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Ingen reservationer i dag',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = _reservations[index];
                        final tableNumbers = (reservation['tableNumbers'] as List<dynamic>?)
                            ?.map((tableNum) => tableNum.toString())
                            .join(', ') ?? 'Ukendt bord';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    reservation['time'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${reservation['partySize']} pers',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            title: Text(
                              reservation['customerName'] ?? 'Ukendt kunde',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Bord: $tableNumbers'),
                                const SizedBox(height: 2),
                                Text(
                                  'Status: ${reservation['status']}',
                                  style: TextStyle(
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _takeOrder(reservation),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Tag Ordre'),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}