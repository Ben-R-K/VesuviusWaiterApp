import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waiterapp/Models/category_model.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<CategoryModel> categories = CategoryModel.getCategories();

  void getCategories()
  {
    categories = CategoryModel.getCategories();
  }

  @override
  void initstate()
  {
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    getCategories();
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchField(),
          SizedBox(height: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Category',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                height: 150,
                color: Colors.green,
                child: ListView.builder(
                  itemBuilder: (context, index){
                    return Container();
                  }
                ),
              )
            ],
          )
        ],
      )
    );
  }

  Container searchField() {
    return Container(
          margin: EdgeInsets.only(top: 40, left: 20, right: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
              color: const Color.fromARGB(185, 0, 0, 0),
              blurRadius: 8.0,
              spreadRadius: 0.0,
            )]
          ),
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(15),
              hintText: 'Search Pancake',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset('assets/icons/search.svg'),
              ),
              suffixIcon: SizedBox(
                width: 100,
                child: IntrinsicHeight(
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      VerticalDivider(
                        color: Colors.black,
                        indent: 10,
                        endIndent: 10,
                        thickness: 1.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset('assets/icons/filter.svg'),
                        ),
                    ],
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none
              )
            ),
          ),
        );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        'Breakfast',
        style: TextStyle(color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold)
        ), 
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {

          },
          child:Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.center,
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: SvgPicture.asset('assets/icons/left-arrow.svg'),
              )
        ),

        actions: [
           GestureDetector(
            onTap: () {
            },
            child: Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
          ),
          child: SvgPicture.asset('assets/icons/dots.svg'),
        ),
           )
        ],
    );
  }
}