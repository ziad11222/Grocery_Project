import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CartWidget extends StatefulWidget {
  const CartWidget({Key? key}) : super(key: key);

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  final _quantityTextController = TextEditingController();
  @override
  void initState() {
    _quantityTextController.text = '1';
    super.initState();
  }
  @override
  void dispose() {
    _quantityTextController.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child:  Row(
        children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                children: [
                  Container(
                    height: 100,
                    width:  100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      ),
                    child: FancyShimmerImage(
                      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSsDATEPFszgI4w9oxexx5FuAFrJAjqhRYcGA&usqp=CAU',
                      boxFit: BoxFit.fill,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(
                      'Title',
                      style:
                      TextStyle(
                        color:Colors.brown,
                        fontSize: 20, 
                        ), 
                    ),
                    SizedBox(height: 16.0,),
                    SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                        _quantityController(
                        fct: (){}, 
                        color: Colors.red, 
                        icon: CupertinoIcons.minus
                        ),
                        Flexible(
                          flex: 1,
                          child: TextField(
                            controller: _quantityTextController,
                            keyboardType: TextInputType.number,
                            maxLines:1 ,
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(),
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp('[0-9]')
                                ),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  if(v.isEmpty){
                                    _quantityTextController.text='1';
                                  }else{
                                    return;
                                  }                              
                                  });
                              },
                          ),
                        ),
                        _quantityController(
                        fct: (){}, 
                        color: Colors.green, 
                        icon: CupertinoIcons.plus
                        )
                      ],),
                    ),
                  ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Icon(
                            CupertinoIcons.cart_badge_minus,
                            color: Colors.red,
                            size: 20,
                            ),
                        ),
                        const SizedBox(height: 5,),
                        Text('\$0.29',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                           ),
                           maxLines: 1,
                           )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],),
    );
  }
  Widget _quantityController ({
  required Function fct, 
  required IconData icon, 
  required Color color
  }){
    return  Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Material(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            child:  InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                fct();
                                },
                              child: Padding(
                                padding:  const EdgeInsets.all(8.0),
                                child: Icon(
                                  icon,
                                  color: Colors.white,),
                              ),
                            ),
                          ),
                        ),
                      );
  }
}