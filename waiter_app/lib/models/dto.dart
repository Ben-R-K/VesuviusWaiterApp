// DTO models for waiter app
class TableDto {
  final int id;
  final String name;
  final bool occupied;

  TableDto({required this.id, required this.name, required this.occupied});

  factory TableDto.fromJson(Map<String, dynamic> j) => TableDto(
        id: j['id'] as int,
        name: j['name'] as String,
        occupied: j['occupied'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'occupied': occupied};
}

class MenuItemDto {
  final int id;
  final String name;
  final String category;
  final double price;

  MenuItemDto({required this.id, required this.name, required this.category, required this.price});

  factory MenuItemDto.fromJson(Map<String, dynamic> j) => MenuItemDto(
        id: j['id'] as int,
        name: j['name'] as String,
        category: j['category'] as String? ?? '',
        price: (j['price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'category': category, 'price': price};
}

class OrderDto {
  final int id;
  final int tableId;
  final List<int> menuItemIds;
  final String status; // queued, in_progress, ready, problem

  OrderDto({required this.id, required this.tableId, required this.menuItemIds, required this.status});

  factory OrderDto.fromJson(Map<String, dynamic> j) => OrderDto(
        id: j['id'] as int,
        tableId: j['tableId'] as int,
        menuItemIds: (j['menuItemIds'] as List).map((e) => e as int).toList(),
        status: j['status'] as String? ?? 'queued',
      );

  Map<String, dynamic> toJson() => {'id': id, 'tableId': tableId, 'menuItemIds': menuItemIds, 'status': status};
}

class ReservationDto {
  final int id;
  final int tableId;
  final String customerName;
  final DateTime from;
  final DateTime to;

  ReservationDto({required this.id, required this.tableId, required this.customerName, required this.from, required this.to});

  factory ReservationDto.fromJson(Map<String, dynamic> j) => ReservationDto(
        id: j['id'] as int,
        tableId: j['tableId'] as int,
        customerName: j['customerName'] as String? ?? '',
        from: DateTime.parse(j['from'] as String),
        to: DateTime.parse(j['to'] as String),
      );

  Map<String, dynamic> toJson() => {'id': id, 'tableId': tableId, 'customerName': customerName, 'from': from.toIso8601String(), 'to': to.toIso8601String()};
}
