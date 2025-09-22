import 'package:flutter/cupertino.dart';
import 'package:waiterapp/Models/dish.dart';

class CreateOrderVm {
  static final ValueNotifier<List<DishModel>> dishesNotifier =
      ValueNotifier<List<DishModel>>([
        DishModel(name: 'Margherita Pizza', price: 8.99, inStock: true),
        DishModel(name: 'Spaghetti Carbonara', price: 10.50, inStock: true),
        DishModel(name: 'Caesar Salad', price: 6.75, inStock: false),
        DishModel(name: 'Grilled Salmon', price: 14.20, inStock: true),
        DishModel(name: 'Cheeseburger', price: 9.40, inStock: true),
        DishModel(name: 'Vegetable Stir Fry', price: 7.80, inStock: false),
        DishModel(name: 'Chicken Tikka Masala', price: 11.60, inStock: true),
        DishModel(name: 'Tomato Soup', price: 4.30, inStock: true),
        DishModel(name: 'Garlic Bread', price: 3.50, inStock: true),
        DishModel(name: 'Chocolate Brownie', price: 5.25, inStock: false),
      ]);
}
