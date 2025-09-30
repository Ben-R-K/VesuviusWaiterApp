import 'package:flutter/material.dart';
import 'package:waiter_app/services/session_manager.dart';
import 'package:waiter_app/services/reservation_manager.dart';
import 'package:waiter_app/models/dto.dart';

class TableAssignmentScreen extends StatefulWidget {
  final SessionManager sessionManager;
  
  const TableAssignmentScreen({super.key, required this.sessionManager});

  @override
  State<TableAssignmentScreen> createState() => _TableAssignmentScreenState();
}

class _TableAssignmentScreenState extends State<TableAssignmentScreen> {
  final TextEditingController _customerController = TextEditingController();
  int _partySize = 2;
  String? _selectedTimeSlot;
  bool _loading = false;
  String? _error;
  List<String> _availableTimeSlots = [];
  List<TableDto> _availableTables = [];
  late ReservationManager _reservationManager;

  // Time slots matching reservation system (15-minute intervals)
  final List<String> _allTimeSlots = [
    "11:00", "11:15", "11:30", "11:45",
    "12:00", "12:15", "12:30", "12:45",
    "13:00", "13:15", "13:30", "13:45",
    "14:00", "14:15", "14:30", "14:45",
    "15:00", "15:15", "15:30", "15:45",
    "16:00", "16:15", "16:30", "16:45",
    "17:00", "17:15", "17:30", "17:45",
    "18:00", "18:15", "18:30", "18:45",
    "19:00", "19:15", "19:30", "19:45",
    "20:00", "20:15", "20:30", "20:45",
    "21:00",
  ];

  @override
  void initState() {
    super.initState();
    print('TableAssignmentScreen: initState called'); // Debug
    _reservationManager = ReservationManager();
    _loadAvailableTimeSlots();
  }

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableTimeSlots() async {
    print('TableAssignmentScreen: _loadAvailableTimeSlots called'); // Debug
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      print('TableAssignmentScreen: Current time is $now'); // Debug
      
      // Filter out past time slots if today
      _availableTimeSlots = _allTimeSlots.where((timeSlot) {
        final timeParts = timeSlot.split(':');
        final slotHour = int.parse(timeParts[0]);
        final slotMinute = int.parse(timeParts[1]);
        final slotDateTime = DateTime(now.year, now.month, now.day, slotHour, slotMinute);
        
        // Only show future time slots
        return slotDateTime.isAfter(now);
      }).toList();

      print('TableAssignmentScreen: Available time slots: $_availableTimeSlots'); // Debug

    } catch (e) {
      print('TableAssignmentScreen: Error loading time slots: $e'); // Debug
      setState(() {
        _error = 'Kunne ikke indlæse ledige tider: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _checkAvailability() async {
    if (_selectedTimeSlot == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final today = DateTime.now();
      final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      print('TableAssignmentScreen: Checking availability for $dateStr $_selectedTimeSlot, party size: $_partySize');
      
      // Use our reservation manager to check availability
      final availableTableNumbers = _reservationManager.getAvailableTablesForTimeSlot(
        dateStr, 
        _selectedTimeSlot!, 
        _partySize
      );

      if (availableTableNumbers.isNotEmpty) {
        setState(() {
          _availableTables = availableTableNumbers
              .map((tableNumber) => TableDto(
                    id: tableNumber.toString(),
                    name: tableNumber.toString(),
                    occupied: false,
                  ))
              .toList();
        });
        print('TableAssignmentScreen: Available tables: $availableTableNumbers');
      } else {
        setState(() {
          _availableTables = [];
          _error = 'Alle borde er reserveret for $_partySize personer kl. $_selectedTimeSlot. Vælg et andet tidspunkt.';
        });
        print('TableAssignmentScreen: No tables available for this time slot');
      }
    } catch (e) {
      print('TableAssignmentScreen: Error checking availability: $e');
      setState(() {
        _error = 'Kunne ikke tjekke tilgængelighed: $e';
        _availableTables = [];
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _createWalkInReservation() async {
    if (_customerController.text.trim().isEmpty) {
      setState(() {
        _error = 'Indtast venligst kundens navn';
      });
      return;
    }

    if (_selectedTimeSlot == null) {
      setState(() {
        _error = 'Vælg venligst et tidspunkt';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final today = DateTime.now();
      final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      // Get the table numbers to reserve
      final tableNumbers = _availableTables.map((table) => int.parse(table.name)).toList();
      
      // Use reservation manager to create the reservation
      final success = _reservationManager.addReservation(
        date: dateStr,
        time: _selectedTimeSlot!,
        partySize: _partySize,
        customerName: _customerController.text.trim(),
        tableNumbers: tableNumbers,
      );

      if (success) {
        // Navigate back to main overview
        if (mounted) {
          Navigator.of(context).pop(); // Go back to table overview
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bord ${tableNumbers.join(', ')} tildelt til ${_customerController.text} ($_partySize personer, kl. $_selectedTimeSlot)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _error = 'Bordene er allerede reserveret. Vælg et andet tidspunkt.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Fejl ved bordtildeling: $e';
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
        title: const Text('Tildel Bord'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),

                  // Customer name input
                  const Text(
                    'Kundens navn:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _customerController,
                    decoration: const InputDecoration(
                      hintText: 'Indtast kundens navn',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Party size selection
                  const Text(
                    'Antal personer:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _partySize > 1 ? () {
                          setState(() {
                            _partySize--;
                            _availableTables.clear();
                          });
                        } : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _partySize.toString(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: _partySize < 8 ? () {
                          setState(() {
                            _partySize++;
                            _availableTables.clear();
                          });
                        } : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Time slot selection
                  const Text(
                    'Vælg tidspunkt (2 timer):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 1,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Fewer columns for larger buttons
                        mainAxisSpacing: 12, // More spacing
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.8, // Wider buttons
                      ),
                      itemCount: _availableTimeSlots.length,
                      itemBuilder: (context, index) {
                        final timeSlot = _availableTimeSlots[index];
                        final isSelected = _selectedTimeSlot == timeSlot;
                        
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedTimeSlot = timeSlot;
                              _availableTables.clear();
                              _error = null;
                            });
                            _checkAvailability();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                            foregroundColor: isSelected ? Colors.white : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16), // More padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                          ),
                          child: Text(
                            timeSlot,
                            style: const TextStyle(
                              fontSize: 16, // Larger text
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Available tables info
                  if (_availableTables.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Ledige borde: ${_availableTables.length}',
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Assign table button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_selectedTimeSlot != null && 
                                 _customerController.text.trim().isNotEmpty && 
                                 _availableTables.isNotEmpty && 
                                 !_loading)
                          ? _createWalkInReservation
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Tildel Bord',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ],
                ),
              ),
      ),
    );
  }
}