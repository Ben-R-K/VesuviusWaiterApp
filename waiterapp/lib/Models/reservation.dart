
import 'package:waiterapp/Models/customer.dart';
import 'package:waiterapp/Models/table.dart';

class ReservationModel{
  int id;
  DateTime reservationDateTime;
  int customers;
  CustomerModel resevator;
  List<TableModel> tables;

  ReservationModel({
    required this.id,
    required this.reservationDateTime,
    required this.customers,
    required this.resevator,
    required this.tables,
  });
}