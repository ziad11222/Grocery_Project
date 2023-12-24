import 'package:flutter/material.dart';
import 'package:grocery_app/main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class password extends StatefulWidget {
  const password({Key? key}) : super(key: key);

  @override
  State<password> createState() => _passwordState();
}

class _passwordState extends State<password> {
  String? password;
  String? token;

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  GlobalKey<FormState> KEY = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Container(
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Grocery Shop',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 35,
                        ),
                      )
                    ],
                  )),
                  color: Colors.greenAccent)),
          Flexible(
              fit: FlexFit.tight,
              flex: 2,
              child: Form(
                key: KEY,
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(height: 50),
                            Padding(
                              padding: EdgeInsets.only(right: 230, bottom: 8),
                              child: Text(
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                  'Token'),
                            ),
                            Padding(
                                padding: EdgeInsets.only(right: 50, left: 50),
                                child: TextFormField(
                                  onChanged: (value) { token = value;},
                                  
                                  
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Enter the token';
                                    }
                                  },
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      hintText: 'Enter the token',
                                      hintStyle: TextStyle(color: Colors.grey)),
                                )),
                            SizedBox(height: 20),
                            Padding(
                              padding: EdgeInsets.only(right: 188, bottom: 8),
                              child: Text(
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                  'Password'),
                            ),
                            Padding(
                                padding: EdgeInsets.only(right: 50, left: 50),
                                child: TextFormField(onChanged: (value) {
                                  setState(() {
                                    password = value;
                                  });
                                },
                                  obscureText: true,
                                  validator: (value) {
                                    if (value!.length < 6) {
                                      return 'password must be more than 6';
                                    }
                                   
                                  },
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      hintText: 'Enter your new password',
                                      hintStyle: TextStyle(color: Colors.grey)),
                                )),
                            SizedBox(height: 10),
                            SizedBox(height: 30),
                            SizedBox(
                              width: 300,
                              height: 50,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.greenAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  onPressed: () {
                                    if (KEY.currentState!.validate()) {
                                      changePassword(password!, token!);
                                    }
                                  },
                                  child: Text('Confirm')),
                            ),
                          ]),
                    )),
              )),
        ],
      )),
    );
  }

  @override
  void initState() {}
  Future<void> changePassword(String pass , String tokken) async {
    final Map<String, dynamic> body = { 'new_password': pass};
    final http.Response response = await http.post(
        Uri.parse('http://34.31.110.154/reset-password/$tokken'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }, body: jsonEncode(body)
    );
    Map<String, dynamic> map = jsonDecode(response.body);
   if(response.statusCode == 200){
    Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return loginpage();
                            },
                          ));
   }
   else {ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid Token')));}
  }

}
