import 'package:waiter_app/services/api_client.dart';
import 'package:waiter_app/models/dto.dart';

class BackendService {
  final ApiClient client;
  final String? token;

  BackendService({required this.client, this.token});

  Future<List<TableDto>> getTables() async {
    final list = await client.getList('/tables', token: token);
    return list.map((e) => TableDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MenuItemDto>> getMenu() async {
    final list = await client.getList('/menu', token: token);
    return list.map((e) => MenuItemDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderDto> createOrder(int tableId, List<int> menuItemIds) async {
    final res = await client.post('/orders', {'tableId': tableId, 'menuItemIds': menuItemIds}, token: token);
    return OrderDto.fromJson(res);
  }

  Future<List<OrderDto>> getOrders({String? status}) async {
    final list = await client.getList('/orders${status != null ? '?status=$status' : ''}', token: token);
    return list.map((e) => OrderDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ReservationDto> createReservation(int tableId, String customerName, DateTime from, DateTime to) async {
    final res = await client.post('/reservations', {'tableId': tableId, 'customerName': customerName, 'from': from.toIso8601String(), 'to': to.toIso8601String()}, token: token);
    return ReservationDto.fromJson(res);
  }
}
