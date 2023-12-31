import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List list = [];
  Map? map;
 
  String? email;
  List<get_cart> cart_products = [];
  bool Trash =false;
  int? trash_id;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(actions: [Trash ? GestureDetector(onTap: () {
          setState(() {
            Trash = false;
            delete(email!, trash_id!);
           

            
            
          });
          
        },child:  Icon(color: Colors.red,Icons.delete),) : SizedBox.shrink()],
          elevation: 0,
          leading: GestureDetector(
            onTap: () {},
            child: Icon(color: Colors.black, Icons.arrow_back_ios_outlined),
          ),
          backgroundColor: Colors.white,
          title: Text(
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              'Cart'),
          centerTitle: true,
        ),
        body: _widget());
        
  }
Widget _widget(){
  if(list.isEmpty || list == null){
    return Center(child: Text(style : TextStyle(fontWeight: FontWeight.bold),'No items found in the cart'),);
  }
  else { return Container(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, int i) {
                          return GestureDetector(onLongPress: () {
                            setState(() {
                              Trash = true;
                              trash_id = list[i]['id'];
                            });
                          },
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.network(
                                    height: 100,
                                    '${list[i]['image']}'),
                                
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        '${list[i]['product_name']}'),
                                    Text(
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        '\$${list[i]['price']}')
                                  ,],
                                ),
                               
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle),
                                  child: Icon(color: Colors.white, Icons.remove),
                                ),
                                
                                Text(
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                    '${list[i]['quantity']}'),
                               
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle),
                                  child: Icon(color: Colors.white, Icons.add),
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, int i) {
                          return Divider();
                        },
                        itemCount: list.length),
                    SizedBox(
                      height: 130,
                    )
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary:  Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      onPressed: () {
                        setState(() {});
                      },
                      child: Text('Checkout')),
                ),
              )
            ],
          ),
        );}
}  
  @override
  void initState() {
    view_cart();
   
    
  }
Future <void> view_cart() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  Map<String, dynamic>? decodedToken = Jwt.parseJwt(token ?? '');
  setState(() {
    email = decodedToken['email'];
    
  });
  http.Response response = await http.get(Uri.parse('http://34.31.110.154/view_cart?client_email=$email'));
  if(response.statusCode == 200){
     
    setState(() {
      list = jsonDecode(response.body);
      for (int i = 0; i < list.length; i++) {
        get_cart cart = get_cart.fromjson(list[i]);
        cart_products.add(cart);
      }
    });

  }
  else if (response.statusCode == 404){
   setState(() {
    list.clear();
      map = jsonDecode(response.body);
   });


  }

}  
Future <void> delete(String email , int product_id) async{
  final Map<String, dynamic> delete_data = {
      'client_email': email,
      'product_id': product_id,
    };
    final http.Response response = await http.post(
      Uri.parse('http://34.31.110.154/removeFromCart'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(delete_data),
    );
    if(response.statusCode == 200){
      setState(() {
        
        view_cart();
      });
    }


}

}
class get_cart {
  String? name;
  String? image;
  int? price;
  int? quantity;
  int? id;
  

  get_cart.fromjson(Map<String, dynamic> list) {
    name = list['product_name'];
    image = list['image'];
    price = list['price'];
    quantity = list['quantity'];
    id = list['id'];
    
  }
}

