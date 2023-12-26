import 'package:flutter/material.dart';
import 'details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? brandValue = 'Brand Name';
  String? priceRangeValue = 'Price Range';
  String? categoryValue = 'Category';
  String? nationalityValue = 'Nationality';
  List<search_product> products = [];
  String? search_name;
  List list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 60,
            margin: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            padding: const EdgeInsets.fromLTRB(8, 2, 6, 2),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(onChanged: (value) {
                    setState(() {
                     products = [];
                    });
                  },onSubmitted: (value) {
                    setState(() {
                      
                      search_name = value;
                      get_search(search_name!);
                     
                    });
                  },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      hintText: 'Search Groceries',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: brandValue,
                    icon: Icon(Icons.arrow_drop_down),
                    items: <String>[
                      'Brand Name',
                      'Brand 1',
                      'Brand 2',
                      'Brand 3'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        brandValue = newValue;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: priceRangeValue,
                    icon: Icon(Icons.arrow_drop_down),
                    items: <String>[
                      'Price Range',
                      'Range 1',
                      'Range 2',
                      'Range 3'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        priceRangeValue = newValue;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: categoryValue,
                    icon: Icon(Icons.arrow_drop_down),
                    items: <String>[
                      'Category',
                      'Category A',
                      'Category B',
                      'Category C'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        categoryValue = newValue;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: nationalityValue,
                    icon: Icon(Icons.arrow_drop_down),
                    items: <String>[
                      'Nationality',
                      'Nationality 1',
                      'Nationality 2',
                      'Nationality 3'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        nationalityValue = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Flexible(
            child: ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (BuildContext, int i) {
                  return SizedBox(width: 10);
                },
                itemCount: products == null ? 0 : products.length ,
                itemBuilder: (context, int i) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return details();
                        }));
                      },
                      child: Stack(
                        children: [
                          Container(
                            height: 300,
                            width: 400,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            child: Padding(
                              padding:
                                  EdgeInsets.only(top: 3, right: 3, left: 3),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      height: 200,
                                      width: 600,
                                      '${products[i].image}',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      '${products[i].name}'),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                      "${products[i].brand}"),
                                  Row(
                                    children: [
                                      Text(
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green),
                                          "\$${products[i].price}"),
                                      SizedBox(
                                        width: 300,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.green),
                                        child: Icon(
                                            color: Colors.white,
                                            Icons.add_shopping_cart_rounded),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ));
                }),
          )
        ],
      ),
    ));
  }
  Future <void> get_search(String name) async{
    http.Response response = await http.get(Uri.parse('http://34.31.110.154/getBySearch?q=$name'));
     list = jsonDecode(response.body);
      print('----------------------------------');
      print(list);
      print('----------------------------------');
     setState(() {
          for(int i = 0; i< list.length ; i++  ){
          search_product product = search_product.fromjson(list[i]);
          products.add(product);

        }
        });

  }
}
class search_product {
  String? name;
  String? brand;
  int? price;
  String? image;
 
  search_product.fromjson(Map<String, dynamic> list) {
    name= list['product_name'];
    brand= list['brand'];
    price= list['price'];
    image= list['image'];
   




  }
}
