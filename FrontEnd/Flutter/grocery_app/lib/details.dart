import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class details extends StatefulWidget {
  

  const details({Key? key,})
      : super(key: key);

  @override
  State<details> createState() => _detailsState();
}

class _detailsState extends State<details> {
  

  

 
  @override
  Widget build(BuildContext context) {
    return _widget();
  }

  Widget _widget() {
    if (false) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        bottomNavigationBar: Container(
          height: 90,
          decoration: BoxDecoration(color: Colors.white60),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(left: 10, top: 30),
                child: Text(
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange),
                    '5'),
              ),
              Container(
                  margin: EdgeInsets.only(left: 12, top: 10),
                  child: Text(
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                      'Price')),
              Container(
                margin:
                    EdgeInsets.only(bottom: 10, top: 10, left: 200, right: 20),
                
              )
            ],
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ListView(
              children: [
                Image.network('https://imageio.forbes.com/specials-images/imageserve/61688aa1d4a8658c3f4d8640/Antonio-Juliano/0x0.jpg?format=jpg&width=960'),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 25,
                    ),
                    Text(
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                        'name')
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Icon(color: Colors.grey, Icons.location_on),
                    Text(
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        'location')
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Icon(color: Colors.grey, Icons.person),
                    Text(
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        'owner')
                  ],
                ),
                Container(
                    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.orangeAccent.withOpacity(0.2)),
                    child: Row(
                      children: [
                        Icon(color: Colors.deepOrange, Icons.bed),
                        Text('6 beds'),
                        SizedBox(
                          width: 30,
                        ),
                        Icon(color: Colors.deepOrange, Icons.bathtub_rounded),
                        Text('6 baths'),
                        SizedBox(
                          width: 30,
                        ),
                        Icon(
                            color: Colors.deepOrange,
                            Icons.fullscreen_outlined),
                        Text('5m')
                      ],
                    )),
                Container(
                  child: Text(
                      style: TextStyle(color: Colors.grey),
                      "As the sun sets over the horizon, the sound of waves crashing against the shore fills the air. A lone seagull swoops down to catch its evening meal, while a group of children build sandcastles nearby. The salty sea breeze carries the scent of sunscreen and saltwater, as beachgoers soak up the last rays of the day. It's the perfect ending to a day filled with fun in the sun."),
                  margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  

  
  
}
