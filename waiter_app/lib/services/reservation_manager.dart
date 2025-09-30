class ReservationManager {
  static final ReservationManager _instance = ReservationManager._internal();
  factory ReservationManager() => _instance;
  ReservationManager._internal();

  // In-memory storage for reservations (in a real app, this would be in a database)
  final List<Map<String, dynamic>> _reservations = [];

  List<Map<String, dynamic>> get reservations => List.unmodifiable(_reservations);

  // Add a new reservation
  bool addReservation({
    required String date,
    required String time,
    required int partySize,
    required String customerName,
    required List<int> tableNumbers,
  }) {
    // Check if any of the tables are already booked for this time
    final conflictingReservation = _reservations.any((reservation) {
      if (reservation['date'] == date && reservation['time'] == time) {
        final existingTables = List<int>.from(reservation['tableNumbers']);
        return tableNumbers.any((table) => existingTables.contains(table));
      }
      return false;
    });

    if (conflictingReservation) {
      print('ReservationManager: Conflict detected for tables $tableNumbers at $time on $date');
      return false; // Booking failed due to conflict
    }

    // Add the reservation
    final reservation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': date,
      'time': time,
      'partySize': partySize,
      'customerName': customerName,
      'tableNumbers': tableNumbers,
      'status': 'CONFIRMED',
      'createdAt': DateTime.now().toIso8601String(),
    };

    _reservations.add(reservation);
    print('ReservationManager: Added reservation for $customerName at $time on $date, tables: $tableNumbers');
    return true; // Booking successful
  }

  // Get reservations for a specific date
  List<Map<String, dynamic>> getReservationsForDate(String date) {
    return _reservations.where((reservation) => reservation['date'] == date).toList();
  }

  // Get all reservations
  List<Map<String, dynamic>> getAllReservations() {
    return List<Map<String, dynamic>>.from(_reservations);
  }

  // Check if tables are available for a specific date and time
  List<int> getAvailableTablesForTimeSlot(String date, String time, int partySize) {
    // All available table numbers (assuming 25 tables)
    final allTables = List.generate(25, (index) => index + 1);
    
    // Find tables that are already booked for this time slot
    final bookedTables = <int>[];
    for (final reservation in _reservations) {
      if (reservation['date'] == date && reservation['time'] == time) {
        bookedTables.addAll(List<int>.from(reservation['tableNumbers']));
      }
    }

    // Remove booked tables from available tables
    final availableTables = allTables.where((table) => !bookedTables.contains(table)).toList();
    
    // Calculate how many tables are needed for the party size
    final tablesNeeded = (partySize / 2).ceil(); // 2 people per table
    
    if (availableTables.length >= tablesNeeded) {
      return availableTables.take(tablesNeeded).toList();
    } else {
      return []; // Not enough tables available
    }
  }

  // Remove a reservation (for cancellation)
  bool removeReservation(String reservationId) {
    final index = _reservations.indexWhere((reservation) => reservation['id'] == reservationId);
    if (index != -1) {
      _reservations.removeAt(index);
      return true;
    }
    return false;
  }

  // Clear all reservations (for testing purposes)
  void clearAllReservations() {
    _reservations.clear();
    print('ReservationManager: All reservations cleared');
  }

  // Initialize with some sample data
  void initializeSampleData() {
    clearAllReservations();
    
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    // Add sample reservations
    addReservation(
      date: dateStr,
      time: '18:00',
      partySize: 4,
      customerName: 'Jensen Familie',
      tableNumbers: [5, 6],
    );
    
    addReservation(
      date: dateStr,
      time: '19:30',
      partySize: 2,
      customerName: 'Nielsen Par',
      tableNumbers: [12],
    );
    
    addReservation(
      date: dateStr,
      time: '20:15',
      partySize: 6,
      customerName: 'Andersen Gruppe',
      tableNumbers: [15, 16, 17],
    );
  }
}