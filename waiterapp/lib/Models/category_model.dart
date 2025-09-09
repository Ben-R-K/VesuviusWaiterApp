import 'package:flutter/material.dart';


class CategoryModel {
  String name;
  String iconPath;
  Color boxColor;

  CategoryModel({
    required this.name,
    required this.iconPath,
    required this.boxColor
  });

  static List<CategoryModel> getCategories()
  {
    List<CategoryModel> categories = [];

    
    categories.add(CategoryModel(
      name: 'Salad',
      iconPath: 'assets/icons/salad.svg',
      boxColor: const Color.fromRGBO(79, 195, 247, 1)
    ));

    categories.add(CategoryModel(
      name: 'Cake',
      iconPath: 'assets/icons/cake.svg',
      boxColor: const Color.fromRGBO(79, 195, 247, 1)
    ));

categories.add(CategoryModel(
      name: 'Pie',
      iconPath: 'assets/icons/pie.svg',
      boxColor: const Color.fromRGBO(79, 195, 247, 1)
    ));

     categories.add(CategoryModel(
      name: 'Smoothie',
      iconPath: 'assets/icons/smoothie.svg',
      boxColor: const Color.fromRGBO(79, 195, 247, 1)
    ));

    return categories;
  }


}
