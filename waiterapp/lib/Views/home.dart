import 'package:flutter/material.dart';
import 'package:waiterapp/Views/orders_overview.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: mainButtons(context),
    );
  }

  Row mainButtons(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.zero))
              ),
            onPressed: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => OrdersOverviewPage()),);
            },
              child: Text('Orders \nOverview',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            )
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.zero))
              ),
              onPressed: () {},
              child: Text('Reservations \nOverview',
                style: TextStyle(
                  color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                ),
              )
            )
          )
        ],
      );
  }
    AppBar appBar() {
    return AppBar(
      title: Text(
        'Tjener app',
      style: TextStyle(color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      ),
      ),
      centerTitle: true,
    );
  }
}