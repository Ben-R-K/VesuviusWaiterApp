
import 'package:waiterapp/Models/dish.dart';
import 'package:waiterapp/Models/order_state.dart';
import 'package:waiterapp/Models/reservation.dart';

class OrderModel
{
  int id;
  List<DishModel> dishes;
  double billPrice;
  ReservationModel reservation;
  OrderState state;
  String? waiterNote;
  String? cookNote;

  OrderModel({
    required this.id,
    required this.dishes,
    required this.billPrice,
    required this.reservation,
    required this.state,
    this. waiterNote,
    this.cookNote,
  });
}