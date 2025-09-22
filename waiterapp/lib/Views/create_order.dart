import 'package:flutter/material.dart';
import 'package:waiterapp/ViewModels/create_order_vm.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final List<String> items = ['1', '2', '3'];
  String? value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        children: [
          Column(
            children: [
              Text('Dishes'),
              DropdownButton<String>(
                items: const [
                  DropdownMenuItem(child: Text('test'), value: 'test'),
                ],
                //items.map(buildMenuItem).toList(),
                onChanged: (value) => setState(() => this.value = value),
              ),
              ListView(),
            ],
          ),
          TextField(),
        ],
      ),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: TextStyle(backgroundColor: Colors.black, fontSize: 20),
    ),
  );
}
