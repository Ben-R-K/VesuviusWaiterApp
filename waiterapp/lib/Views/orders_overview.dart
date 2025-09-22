import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waiterapp/Models/order.dart';
import 'package:waiterapp/ViewModels/orders_overview_vm.dart';
import 'package:waiterapp/Views/create_order.dart';

class OrdersOverviewPage extends StatefulWidget {
  const OrdersOverviewPage({super.key});

  @override
  State<OrdersOverviewPage> createState() => _OrdersOverviewPageState();
}

class _OrdersOverviewPageState extends State<OrdersOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ordersAppBar(),
      body: waiterappListview(),
      bottomNavigationBar: bottomOrdersBar(),
    );
  }

  AppBar ordersAppBar() {
    return AppBar(
      title: Text(
        'OrdersOverview',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.blue,
      shadowColor: Colors.black,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateOrderPage()),
            );
          },
          icon: SvgPicture.asset('assets/icons/plus.svg'),
        ),
      ],
    );
  }

  ValueListenableBuilder<List<OrderModel>> waiterappListview() {
    return ValueListenableBuilder<List<OrderModel>>(
      valueListenable: OrdersOverviewVm.recordsNotifier,
      builder: (context, records, _) {
        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: listviewItem(records, index),
              ),
            );
          },
        );
      },
    );
  }

  Column listviewItem(List<OrderModel> records, int index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  margin: const EdgeInsets.only(left: 8.0, top: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'ID:${records[index].id.toString()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  margin: const EdgeInsets.only(left: 8.0, top: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    '${records[index].reservation.resevator.firstName} ${records[index].reservation.resevator.lastName}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  margin: const EdgeInsets.only(left: 8.0, top: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Tables:${records[index].reservation.tables.map((e) => e.id).toString()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Spacer(),
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset('assets/icons/edit.svg'),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(6.0),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset('assets/icons/trashcan.svg'),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(6.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.all(4.0),
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            records[index].dishes.map((d) => d.name).toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  BottomAppBar bottomOrdersBar() {
    return BottomAppBar(color: Colors.blue);
  }
}
