// DTO models for waiter app
class TableDto {
  // IDs in the backend may be strings (UUID-like) or integers. Use String
  // internally for robustness.
  final String id;
  final String name;
  final bool occupied;

  TableDto({required this.id, required this.name, required this.occupied});

  factory TableDto.fromJson(Map<String, dynamic> j) {
    final rawId = j['id'];
    return TableDto(
      id: rawId != null ? rawId.toString() : '',
      name: (j['name'] ?? j['label'] ?? j['title'] ?? '').toString(),
      occupied: j['occupied'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'occupied': occupied};
}

class MenuItemDto {
  // Backend uses string IDs; price may be integer or double.
  final String id;
  final String name;
  final String? description;
  final String category;
  final double price;
  final String? image;

  MenuItemDto({required this.id, required this.name, this.description, required this.category, required this.price, this.image});

  factory MenuItemDto.fromJson(Map<String, dynamic> j, {String? category}) => MenuItemDto(
        id: (j['id'] ?? j['uuid'] ?? j['uid']).toString(),
        name: (j['name'] ?? '').toString(),
        description: j['description'] as String?,
        category: category ?? (j['category'] as String? ?? ''),
        price: j['price'] != null ? (j['price'] as num).toDouble() : 0.0,
        image: j['image'] as String?,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'description': description, 'category': category, 'price': price, 'image': image};
}

class OrderDto {
  final String id;
  final String tableId;
  final List<String> menuItemIds;
  final String status; // queued, in_progress, ready, problem

  OrderDto({required this.id, required this.tableId, required this.menuItemIds, required this.status});

  factory OrderDto.fromJson(Map<String, dynamic> j) => OrderDto(
        id: (j['id'] ?? j['uuid']).toString(),
        tableId: (j['tableId'] ?? j['table'] ?? j['tableId']).toString(),
        menuItemIds: (j['menuItemIds'] as List? ?? j['items'] as List? ?? []).map((e) => e.toString()).toList(),
        status: j['status'] as String? ?? 'queued',
      );

  Map<String, dynamic> toJson() => {'id': id, 'tableId': tableId, 'menuItemIds': menuItemIds, 'status': status};
}

class ReservationDto {
  final String id;
  final String tableId;
  final String customerName;
  final DateTime from;
  final DateTime to;

  ReservationDto({required this.id, required this.tableId, required this.customerName, required this.from, required this.to});

  factory ReservationDto.fromJson(Map<String, dynamic> j) => ReservationDto(
        id: (j['id'] ?? j['uuid']).toString(),
        tableId: (j['tableId'] ?? j['table']).toString(),
        customerName: (j['customerName'] ?? j['name'] ?? '').toString(),
        from: DateTime.parse(j['from'] as String),
        to: DateTime.parse(j['to'] as String),
      );

  Map<String, dynamic> toJson() => {'id': id, 'tableId': tableId, 'customerName': customerName, 'from': from.toIso8601String(), 'to': to.toIso8601String()};
}
