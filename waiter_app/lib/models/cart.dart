import 'package:waiter_app/models/dto.dart';

class CartItem {
  final MenuItemDto menuItem;
  int quantity;
  String? notes;

  CartItem({required this.menuItem, this.quantity = 1, this.notes});
}

class TableOrderCart {
  final TableDto table;
  final List<CartItem> items = [];

  TableOrderCart(this.table);

  void addItem(MenuItemDto menuItem, {int quantity = 1, String? notes}) {
    final existing = items.firstWhere(
      (item) => item.menuItem.id == menuItem.id && item.notes == notes,
      orElse: () => CartItem(menuItem: menuItem, quantity: 0, notes: notes),
    );
    if (items.contains(existing)) {
      existing.quantity += quantity;
    } else {
      items.add(CartItem(menuItem: menuItem, quantity: quantity, notes: notes));
    }
  }

  void updateItem(MenuItemDto menuItem, {int? quantity, String? notes}) {
    final idx = items.indexWhere((item) => item.menuItem.id == menuItem.id);
    if (idx != -1) {
      if (quantity != null) items[idx].quantity = quantity;
      if (notes != null) items[idx].notes = notes;
    }
  }

  void removeItem(MenuItemDto menuItem, {String? notes}) {
    items.removeWhere((item) => item.menuItem.id == menuItem.id && (item.notes ?? '') == (notes ?? ''));
  }

  void clear() => items.clear();

  bool get isEmpty => items.isEmpty;
}
