import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class DetailPage extends StatefulWidget {
  final int ID;
  const DetailPage({Key? key, required this.ID}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map? map;
  int quantity = 1;
  String? email;
  Map? map_24hour;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: map == null || map_24hour == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                const SizedBox(height: 20),
                header(),
                const SizedBox(height: 20),
                image(),
                details(),
              ],
            ),
    );
  }

  Container details() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${map!['product_name']}',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '\$${map!['new_price']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    map!['discount'] != 0
                        ? Text(
                            style: TextStyle(color: Colors.green),
                            '${map!['discount']}%')
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              Material(
                color: Colors.green,
                borderRadius: BorderRadius.circular(30),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                      icon: const Icon(Icons.remove),
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '$quantity',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                      icon: const Icon(Icons.add),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.flag, color: Colors.red, size: 10),
              const SizedBox(width: 4),
              Text(
                '${map!['nationality']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.flag, color: Colors.red, size: 10),
              const SizedBox(width: 4),
              Text(
                '${map!['brand']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              
              const SizedBox(width: 4),
              Column(
                children: [
                  Text(
                    'Users Purchased :${map_24hour!['total_users_purchased']}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),Text(
                    'in last 24 hours :${map_24hour!['users_purchased_last_24_hours']}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'About Food',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${map!['details']}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 30),
          Material(
            color: Colors.green,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                addToCart(email!, widget.ID, quantity);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: const Text(
                  'Add to Cart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  SizedBox image() {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.green[300]!,
                      blurRadius: 16,
                      offset: Offset(0, 16)),
                ],
                borderRadius: BorderRadius.circular(250),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(250),
                child: Image.network(
                  '${map!['image']}',
                  fit: BoxFit.cover,
                  width: 250,
                  height: 250,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Material(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            child: const BackButton(
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const Icon(Icons.location_on, color: Colors.green, size: 18),
          const Text(
            'Details Food',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Material(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 47,
                width: 47,
                alignment: Alignment.center,
                child: const Icon(Icons.abc, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    getData();
    initializeData();
  }

  Future<void> initializeData() async {
    await get_info(widget.ID);
    await getData();
    await get_24hours();
  }

  Future<void> get_info(int id) async {
    http.Response response = await http
        .get(Uri.parse('http://34.31.110.154/getProductInfo?product_id=$id'));
    if (response.statusCode == 200) {
      setState(() {
        map = json.decode(response.body);
      }); 
    }
  }

  getData() async {
    String? token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    Map<String, dynamic>? decodedToken = Jwt.parseJwt(token ?? '');
    if (decodedToken != null) {
      setState(() {
        email = decodedToken['email'];
      });
    }
  }

  Future<void> get_24hours() async {
    http.Response response = await http.get(Uri.parse(
        'http://34.31.110.154/productPurchaseStats?product_id=${widget.ID}'));
    if (response.statusCode == 200) {
      setState(() {
        map_24hour = json.decode(response.body);
      });
    }
  }

  Future<void> addToCart(String email, int product_id, int quantity) async {
    final Map<String, dynamic> add_data = {
      'client_email': email,
      'product_id': product_id,
      'quantity': quantity
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
