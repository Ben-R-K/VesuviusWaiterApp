import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.zero))
                ),
              onPressed: () {},
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
        ),
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