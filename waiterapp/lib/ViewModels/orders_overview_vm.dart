
import 'package:flutter/cupertino.dart';
import 'package:waiterapp/Models/customer.dart';
import 'package:waiterapp/Models/dish.dart';
import 'package:waiterapp/Models/order.dart';
import 'package:waiterapp/Models/order_state.dart';
import 'package:waiterapp/Models/reservation.dart';
import 'package:waiterapp/Models/table.dart';

class OrdersOverviewVm {
  static final ValueNotifier<List<OrderModel>> recordsNotifier = ValueNotifier<List<OrderModel>>(
    [OrderModel(
    id: 1,
    dishes: [
      DishModel(name: 'Margherita Pizza', price: 8.5, inStock: true),
      DishModel(name: 'Caesar Salad', price: 5.0, inStock: true),
    ],
    billPrice: 13.5,
    reservation: ReservationModel(
      id: 101,
      reservationDateTime: DateTime(2025, 9, 12, 18, 30),
      customers: 2,
      resevator: CustomerModel(
        id: 1,
        firstName: 'Alice',
        lastName: 'Johnson',
        tlfnr: 123456789,
        email: 'alice.johnson@example.com',
      ),
      tables: [
        TableModel(id: 1),
        TableModel(id: 2),
      ],
    ),
    state: OrderState.ordered,
    waiterNote: 'Allergic to nuts',
    cookNote: 'Use lactose-free cheese',
  ),
  OrderModel(
    id: 2,
    dishes: [
      DishModel(name: 'Spaghetti Bolognese', price: 10.0, inStock: true),
      DishModel(name: 'Garlic Bread', price: 3.0, inStock: true),
      DishModel(name: 'Tiramisu', price: 4.5, inStock: false),
    ],
    billPrice: 17.5,
    reservation: ReservationModel(
      id: 102,
      reservationDateTime: DateTime(2025, 9, 12, 19, 00),
      customers: 3,
      resevator: CustomerModel(
        id: 2,
        firstName: 'Bob',
        lastName: 'Miller',
        tlfnr: 987654321,
        email: 'bob.miller@example.com',
      ),
      tables: [
        TableModel(id: 3),
      ],
    ),
    state: OrderState.cooking,
    waiterNote: 'Birthday celebration, bring candles',
    cookNote: 'Add extra sauce',
  ),
  OrderModel(
    id: 3,
    dishes: [
      DishModel(name: 'Grilled Salmon', price: 14.0, inStock: true),
      DishModel(name: 'Mashed Potatoes', price: 4.0, inStock: true),
      DishModel(name: 'Lemon Tart', price: 5.5, inStock: true),
    ],
    billPrice: 23.5,
    reservation: ReservationModel(
      id: 103,
      reservationDateTime: DateTime(2025, 9, 12, 20, 00),
      customers: 4,
      resevator: CustomerModel(
        id: 3,
        firstName: 'Carla',
        lastName: 'Gomez',
        tlfnr: 112233445,
        email: 'carla.gomez@example.com',
      ),
      tables: [
        TableModel(id: 4),
        TableModel(id: 5),
      ],
    ),
    state: OrderState.orderComplete,
    waiterNote: 'Table near window',
    cookNote: 'Cook salmon medium-rare',
  ),
  OrderModel(
    id: 4,
    dishes: [
      DishModel(name: 'Beef Burger', price: 9.0, inStock: true),
      DishModel(name: 'Fries', price: 3.5, inStock: true),
      DishModel(name: 'Cola', price: 2.0, inStock: true),
    ],
    billPrice: 14.5,
    reservation: ReservationModel(
      id: 104,
      reservationDateTime: DateTime(2025, 9, 12, 21, 00),
      customers: 1,
      resevator: CustomerModel(
        id: 4,
        firstName: 'David',
        lastName: 'Lee',
        tlfnr: 556677889,
        email: 'david.lee@example.com',
      ),
      tables: [
        TableModel(id: 6),
      ],
    ),
    state: OrderState.complications,
    waiterNote: 'Guest is in a hurry',
    cookNote: 'Kitchen delay due to missing ingredients',
  ),
]
  );
  }