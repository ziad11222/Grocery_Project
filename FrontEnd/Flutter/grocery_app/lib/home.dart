import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grocery_app/cart_screen.dart';
import 'package:grocery_app/details.dart';
import 'details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

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
  final FocusNode _focusNode = FocusNode();
  Map<String, dynamic>? decodedToken;
  String? image;
  List<allproduct> products = [];
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
 Widget _widget(){
  if(products.isEmpty || products == null){
    return CircularProgressIndicator();
  }
  else {return SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(image == null
                                    ? 'https://imageio.forbes.com/specials-images/imageserve/61688aa1d4a8658c3f4d8640/Antonio-Juliano/0x0.jpg?format=jpg&width=960'
                                    : '$image')),
                            SizedBox(
                              width: 30,
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
                            SizedBox(
                              width: 40,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return CartScreen();
                                  },
                                ));
                              },
                              child: Icon(
                                  size: 30,
                                  color: Colors.white,
                                  Icons.shopping_cart_outlined),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white60.withOpacity(1),
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(25)),
                              hintText: 'Search here...',
                              prefixIcon:
                                  Icon(color: Colors.black, Icons.search),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        )
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
                      height: 230,
                      child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return details();
                                  },
                                ));
                              },
                              child: Container(
                                width: 200,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 3, right: 3, left: 3),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          height: 150,
                                          width: 300,
                                          'https://s.yimg.com/uu/api/res/1.2/5KxZMxNs4haV4ILfIq_6GA--~B/aD0yNzc1O3c9NDIwMDtzbT0xO2FwcGlkPXl0YWNoeW9u/http://media.zenfs.com/en_us/News/ap_webfeeds/ae4fd9d1ca814db587687a622c8b4ff4.jpg',
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
                                          'item title'),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                          "fresh fruit 2KG"),
                                      Row(
                                        children: [
                                          Text(
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green),
                                              "\$200"),
                                          SizedBox(
                                            width: 120,
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.green),
                                            child: Icon(
                                                color: Colors.white,
                                                Icons
                                                    .add_shopping_cart_rounded),
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
                          itemCount: 10),
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
                          int item = i *2;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return details();
                                    },
                                  ));
                                },
                                child: Container(
                                  width: 190,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 3, right: 3, left: 3),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            height: 150,
                                            width: 300,
                                            '${products[item].image}',
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
                                            '${products[item].name}'),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black),
                                            "${products[item].brand}"),
                                        Row(
                                          children: [
                                            Text(
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green),
                                                "\$${products[item].price}"),
                                            SizedBox(
                                              width: 110,
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.green),
                                              child: Icon(
                                                  color: Colors.white,
                                                  Icons
                                                      .add_shopping_cart_rounded),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return details();
                                    },
                                  ));
                                },
                                child: Container(
                                  width: 190,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 3, right: 3, left: 3),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            height: 150,
                                            width: 300,
                                            '${products[item+1].image}',
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
                                            '${products[item+1].name}'),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black),
                                            "${products[item+1].brand}"),
                                        Row(
                                          children: [
                                            Text(
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green),
                                                "\$${products[item+1].price}"),
                                            SizedBox(
                                              width: 110,
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.green),
                                              child: Icon(
                                                  color: Colors.white,
                                                  Icons
                                                      .add_shopping_cart_rounded),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: 10,
                          );
                        },
                        itemCount: 10),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              )
            ]),
          );}
 } 

  @override
  void initState() {
    getData();
    get_homepage();
  }

  getData() async {
    String? token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    Map<String, dynamic>? decodedToken = Jwt.parseJwt(token ?? '');
    if (decodedToken != null) {
      setState(() {
        image = decodedToken['profile_image'];
      });
    }
  }

  Future<void> get_homepage() async {
    http.Response response =
        await http.get(Uri.parse('http://34.31.110.154/getAllProduct'));
        List list = json.decode(response.body);
        print('----------------------------------------------------------');
        print(list);
        print('----------------------------------------------------------');
        print(list.length);
        print('----------------------------------------------------------');
        setState(() {
          for(int i = 0; i< list.length ; i++  ){
          allproduct Allproduct = allproduct.fromjson(list[i]);
          products.add(Allproduct);

        }
        });
         print('----------------------------------------------------------');
        print(products[0].image);
    print('----------------------------------------------------------');
  }
}
class allproduct {
  String? name;
  String? brand;
  int? price;
  String? image;
 
  allproduct.fromjson(Map<String, dynamic> list) {
    name= list['product_name'];
    brand= list['brand'];
    price= list['price'];
    image= list['image'];
   




  }
}
