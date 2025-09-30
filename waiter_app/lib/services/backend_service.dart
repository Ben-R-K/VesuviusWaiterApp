import 'package:waiter_app/services/api_client.dart';
import 'package:waiter_app/models/dto.dart';



class BackendService {
  final ApiClient client;
  final String? token;

  BackendService({ApiClient? client, this.token})
      : client = client ?? ApiClient();

  Future<List<TableDto>> getTables() async {
    try {
      final list = await client.getList('/api/tables', token: token);
      return list.map((e) => TableDto.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Some backends may not expose /api/tables; return an empty list and
      // let the UI decide whether to show menu data instead.
      return <TableDto>[];
    }
  }

  Future<List<MenuItemDto>> getMenu() async {
    // The backend returns a list of categories each with a `menuItems` array.
    final list = await client.getList('/api/menu', token: token);
    final items = <MenuItemDto>[];
    for (final cat in list) {
      final catMap = cat as Map<String, dynamic>;
      final categoryName = (catMap['name'] ?? catMap['title'] ?? '').toString();
      final mi = catMap['menuItems'] as List<dynamic>? ?? [];
      for (final m in mi) {
        items.add(MenuItemDto.fromJson(m as Map<String, dynamic>, category: categoryName));
      }
    }
    return items;
  }

  Future<OrderDto> createOrder(String tableId, List<String> menuItemIds, {String? customerId, String? reservationId, String? notes, String? tableName}) async {
    // The backend expects: { customerId OR tableNumber, reservationId, items: [{menuItemId, quantity}], notes }
    final items = menuItemIds.map((id) => {'menuItemId': id, 'quantity': 1}).toList();
    final body = {
      if (customerId != null) 'customerId': customerId,
      if (reservationId != null) 'reservationId': reservationId,
      if (customerId == null) 'tableNumber': tableName ?? tableId, // Use tableName (actual number) for walk-ins
      'items': items,
      if (notes != null) 'notes': notes,
    };
    final res = await client.post('/api/orders', body, token: token);
    return OrderDto.fromJson(res['order'] ?? res);
  }

  Future<List<OrderDto>> getOrders({String? status}) async {
    final response = await client.get('/api/orders${status != null ? '?status=$status' : ''}', token: token);
    final data = response['orders'] ?? response['data'] ?? response;
    if (data is List) {
      return data.map((e) => OrderDto.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<OrderDto> updateOrderStatus(String orderId, String status) async {
    final res = await client.patch('/api/orders/$orderId/status', {'status': status}, token: token);
    return OrderDto.fromJson(res['order'] ?? res);
  }

  Future<ReservationDto> createReservation(int tableId, String customerName, DateTime from, DateTime to) async {
    final res = await client.post('/api/reservations', {'tableId': tableId, 'customerName': customerName, 'from': from.toIso8601String(), 'to': to.toIso8601String()}, token: token);
    return ReservationDto.fromJson(res);
  }

  /// Check reservation availability for a specific date, time, and party size
  /// Uses the same API as the web reservation system
  Future<Map<String, dynamic>> checkReservationAvailability(String date, String time, int partySize) async {
    final url = '/api/reservations?date=$date&time=$time&partySize=$partySize';
    final response = await client.get(url, token: token);
    return response;
  }

  /// Create a walk-in reservation (immediate seating)
  /// Uses the reservation API but with minimal customer data
  Future<Map<String, dynamic>> createWalkInReservation(String date, String time, int partySize, String customerName) async {
    final body = {
      'date': date,
      'time': time,
      'partySize': partySize,
      'customerData': {
        'firstName': customerName.split(' ').first,
        'lastName': customerName.split(' ').length > 1 ? customerName.split(' ').skip(1).join(' ') : '.',
        'email': 'walkin@vesuvius.dk', // Default email for walk-ins
        'phone': '', // Optional for walk-ins
      },
    };
    final response = await client.post('/api/reservations', body, token: token);
    return response;
  }
}
