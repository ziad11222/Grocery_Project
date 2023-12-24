import 'package:flutter/material.dart';
import 'package:grocery_app/reset_password.dart';
import 'signup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class check extends StatefulWidget {
  const check({Key? key}) : super(key: key);

  @override
  State<check> createState() => _checkState();
}

class _checkState extends State<check> {
  String? email;
  GlobalKey<FormState> KEY = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Form(
        key: KEY,
        child: Container(
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Grocery Shop',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 50,
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 50, left: 50),
                  child: SizedBox(
                    width: 2000,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your email';
                        }
                      },
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black), // set border color here
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white30), // set border color here
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                            borderRadius: BorderRadius.circular(10)),
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    onPressed: () {
                      if (KEY.currentState!.validate()) {
                        send_OTP(email!);
                      }
                    },
                    child: Container(
                        margin: EdgeInsets.all(20),
                        child: Text(
                            style: TextStyle(color: Colors.black),
                            'Send Confirmation'))),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        style: TextStyle(fontWeight: FontWeight.bold),
                        'Create New Account?'),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return signup();
                            },
                          ));
                        },
                        child: Text(
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.withGreen(10)),
                            ' Register'))
                  ],
                )
              ],
            )),
            color: Colors.greenAccent),
      )),
    );
  }

  Future<void> send_OTP(String email) async {
    final Map<String, dynamic> forgetData = {'email': email};
    final http.Response response =
        await http.post(Uri.parse('http://34.31.110.154/forgot-password'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(forgetData));
    Map<String, dynamic> map = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return password();
        },
      ));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User Not Found')));
    }
  }
}
