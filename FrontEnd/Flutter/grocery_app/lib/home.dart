import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grocery_app/cart_screen.dart';
import 'details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: home(),
  ));
}

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  List list = [];
  Map<String, dynamic>? decodedToken;
  String? image;
  String? name;
  String? email;
  List<allproduct> products = [];
  List<discount__products> discounts = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Center(
          child: _widget(),
        ),
      ),
    );
  }

  Widget _widget() {
    if (products.isEmpty ||
        products == null ||
        products.length != list.length ||
        discounts.isEmpty ||
        discounts == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 1,
                        ),
                        Column(
                          children: [
                            CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(image == null
                                    ? 'https://imageio.forbes.com/specials-images/imageserve/61688aa1d4a8658c3f4d8640/Antonio-Juliano/0x0.jpg?format=jpg&width=960'
                                    : '$image')),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                '$name')
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                                'Welcome'),
                            Text(
                                style: TextStyle(color: Colors.white),
                                'What do you want to Buy?'),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            pushNewScreen(
                              context,
                              screen: CartScreen(),
                              withNavBar: false,
                            );
                          },
                          child: Icon(
                              size: 30,
                              color: Colors.white,
                              Icons.shopping_cart_outlined),
                        ),
                        SizedBox(
                          width: 1,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ]),
              decoration: BoxDecoration(color: Colors.green)),
          SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 500,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                        'Discounts'),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 260,
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, int i) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return DetailPage(ID: discounts[i].id!,);
                              },
                            ));
                          },
                          child: Container(
                            width: 250,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            child: Padding(
                              padding:
                                  EdgeInsets.only(top: 3, right: 3, left: 3),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      height: 150,
                                      width: 300,
                                      '${discounts[i].image}',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                            '${discounts[i].name}'),
                                      ),
                                      Flexible(
                                          child: Text(
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.start,
                                              '${discounts[i].discount}%')),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                      "${discounts[i].brand}"),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                            style: TextStyle(
                                                fontSize: 20,
                                                decorationColor: Colors.red,
                                                decorationThickness: 3,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green),
                                            text: "\$${discounts[i].price}"),
                                      ),
                                      Text(
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red),
                                          '\$${discounts[i].newPrice}'),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            addToCart(email!, discounts[i].id!);
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.green),
                                          child: Icon(
                                              color: Colors.white,
                                              Icons.add_shopping_cart_rounded),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, int i) {
                        return SizedBox(
                          width: 10,
                        );
                      },
                      itemCount: discounts.length),
                ),
                Row(
                  children: [
                    Text(
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                        'All'),
                  ],
                ),
                ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, int i) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return DetailPage(ID: products[i].id!,);
                                },
                              ));
                            },
                            child: Container(
                              width: 370,
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
                                        width: 370,
                                        '${products[i].image}',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                        '${products[i].name}'),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.black),
                                        "${products[i].brand}"),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green),
                                            "\$${products[i].price}"),
                                        GestureDetector(onTap: () {
                                          setState(() {
                                            addToCart(email!, products[i].id!);
                                          });
                                        },
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.green),
                                            child: Icon(
                                                color: Colors.white,
                                                Icons.add_shopping_cart_rounded),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 10,
                      );
                    },
                    itemCount: products.length),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          )
        ]),
      );
    }
  }

  @override
  void initState() {
    getData();
    initializeData();
  }

  Future<void> initializeData() async {
    await get_homepage();
    await get_discounts();
  }

  getData() async {
    String? token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    Map<String, dynamic>? decodedToken = Jwt.parseJwt(token ?? '');
    if (decodedToken != null) {
      setState(() {
        image = decodedToken['profile_image'];
        name = decodedToken['username'];
        email = decodedToken['email'];
      });
    }
  }

  Future<void> get_homepage() async {
    http.Response response =
        await http.get(Uri.parse('http://34.31.110.154/getAllProduct'));
    if (response.statusCode == 200) {
      list = json.decode(response.body);

      setState(() {
        for (int i = 0; i < list.length; i++) {
          allproduct Allproduct = allproduct.fromjson(list[i]);
          products.add(Allproduct);
        }
      });
    }
  }

  Future<void> get_discounts() async {
    http.Response response =
        await http.get(Uri.parse('http://34.31.110.154/discounted_products'));
    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      setState(() {
        for (int i = 0; i < list.length; i++) {
          discount__products Discounted_products =
              discount__products.fromjson(list[i]);
          discounts.add(Discounted_products);
        }
      });
    }
  }

  Future<void> addToCart(String email, int product_id) async {
    final Map<String, dynamic> add_data = {
      'client_email': email,
      'product_id': product_id,
      'quantity': 1
    };
    final http.Response response = await http.post(
      Uri.parse('http://34.31.110.154/addToCart'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(add_data),
    );
    if (response.statusCode == 200) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text('Product added to the cart')));
      });
    }
  }
}

class allproduct {
  String? name;
  String? brand;
  int? price;
  String? image;
  String? newPrice;
  int? discount;
  int? id;

  allproduct.fromjson(Map<String, dynamic> list) {
    name = list['product_name'];
    brand = list['brand'];
    price = list['price'];
    image = list['image'];
    newPrice = list['new_price'];
    discount = list['discount'];
    id = list['id'];
  }
}

class discount__products {
  String? name;
  String? brand;
  int? price;
  String? image;
  String? newPrice;
  int? discount;
  int? id;

  discount__products.fromjson(Map<String, dynamic> list) {
    name = list['product_name'];
    brand = list['brand'];
    price = list['price'];
    image = list['image'];
    newPrice = list['new_price'];
    discount = list['discount'];
    id = list['id'];
  }
}
