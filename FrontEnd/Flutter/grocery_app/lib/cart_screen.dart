
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:grocery_app/cart/cart_widget.dart';

class CartScreen extends StatelessWidget{
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: Text('Cart(2)'),
        actions: [
        IconButton(onPressed: (){}, icon: Icon(
          IconlyBroken.delete,
          color: Colors.red,
        ),),

      ]),
      body: Column(
        children: [
          _checkout(),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
                itemBuilder: (ctx,index){
                return CartWidget();
              },),
          ),
        ],
      ),
    );
  }
  Widget _checkout(){
   return SizedBox(
            width: double.infinity,
            height: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:12),
              child: Row(
                children: [
                  Material(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Order Now', 
                        style: TextStyle(
                          fontSize: 20
                        ),),
                      ),
                    )
                  ),
                  const Spacer(),
                  FittedBox(
                    child: Text('Total: \$222',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),),
                  )
                ],
              ),
            ),
          );
  }
}
