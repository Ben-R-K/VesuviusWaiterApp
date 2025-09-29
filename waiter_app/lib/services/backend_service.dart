import 'package:waiter_app/services/api_client.dart';
import 'package:waiter_app/models/dto.dart';


import '../config.dart';

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

  Future<OrderDto> createOrder(String tableId, List<String> menuItemIds) async {
    final res = await client.post('/api/orders', {'tableId': tableId, 'menuItemIds': menuItemIds}, token: token);
    return OrderDto.fromJson(res);
  }

  Future<List<OrderDto>> getOrders({String? status}) async {
    final list = await client.getList('/api/orders${status != null ? '?status=$status' : ''}', token: token);
    return list.map((e) => OrderDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ReservationDto> createReservation(int tableId, String customerName, DateTime from, DateTime to) async {
    final res = await client.post('/api/reservations', {'tableId': tableId, 'customerName': customerName, 'from': from.toIso8601String(), 'to': to.toIso8601String()}, token: token);
    return ReservationDto.fromJson(res);
  }
}
