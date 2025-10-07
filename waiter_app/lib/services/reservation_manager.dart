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
      return false; 
    }
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
    return true;
  }

  List<Map<String, dynamic>> getReservationsForDate(String date) {
    return _reservations.where((reservation) => reservation['date'] == date).toList();
  }

  List<Map<String, dynamic>> getAllReservations() {
    return List<Map<String, dynamic>>.from(_reservations);
  }

  List<int> getAvailableTablesForTimeSlot(String date, String time, int partySize) {
    final allTables = List.generate(25, (index) => index + 1);
    
    final bookedTables = <int>[];
    for (final reservation in _reservations) {
      if (reservation['date'] == date && reservation['time'] == time) {
        bookedTables.addAll(List<int>.from(reservation['tableNumbers']));
      }
    }

    final availableTables = allTables.where((table) => !bookedTables.contains(table)).toList();
    
    final tablesNeeded = (partySize / 2).ceil(); 
    
    if (availableTables.length >= tablesNeeded) {
      return availableTables.take(tablesNeeded).toList();
    } else {
      return [];
    }
  }

  bool removeReservation(String reservationId) {
    final index = _reservations.indexWhere((reservation) => reservation['id'] == reservationId);
    if (index != -1) {
      _reservations.removeAt(index);
      return true;
    }
    return false;
  }

  void clearAllReservations() {
    _reservations.clear();
    print('ReservationManager: All reservations cleared');
  }

  void initializeSampleData() {
    clearAllReservations();
    
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
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