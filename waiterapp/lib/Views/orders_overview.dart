import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waiterapp/Models/order.dart';
import 'package:waiterapp/ViewModels/orders_overview_vm.dart';

class OrdersOverviewPage extends StatefulWidget {
  const OrdersOverviewPage({super.key});

  @override
  State<OrdersOverviewPage> createState() => _OrdersOverviewPageState();
}

class _OrdersOverviewPageState extends State<OrdersOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<OrderModel>>(
        valueListenable: OrdersOverviewVm.recordsNotifier,
        builder: (context, records,_){
          return ListView.builder(itemCount: records.length,
          itemBuilder: (context, index) {
            return Padding(padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 200,
              color: Colors.blue,
              child: Row(
                children: [
                  Column(
                    children: [
                      Text('${records[index].reservation.resevator.firstName} ${records[index].reservation.resevator.lastName}',),
                      Text(records[index].reservation.tables.map((e) => e.id,).toString())
                    ],
                  )
                ],
              ),
              ),
            );
          },
          );
        }),
      bottomNavigationBar: bottomOrdersBar(),
      );
  }

  BottomAppBar bottomOrdersBar() {
    return BottomAppBar(
      color: Colors.blue,
      child: Row(
        children: [
          IconButton(onPressed: (){}, icon: SvgPicture.asset('assets/icons/plus.svg'),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
          ),),
        ],
      ),
    );
  }
}