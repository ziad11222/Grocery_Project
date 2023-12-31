import 'package:flutter/material.dart';
import 'signup.dart';
import 'forgetpassword.dart';
import 'Homepage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: loginpage(),
  ));
}

class loginpage extends StatefulWidget {
  const loginpage({Key? key}) : super(key: key);

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  var email;
  var password;
  var response;
  var image;
  bool isClosedeye =true;
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
                            Text(
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                'Welcome Back!'),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    style: TextStyle(color: Colors.grey),
                                    "Don't have an account?"),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return signup();
                                      },
                                    ));
                                  },
                                  child: Text(
                                      style:
                                          TextStyle(color: Colors.greenAccent),
                                      'Register'),
                                )
                              ],
                            ),
                            SizedBox(height: 50),
                            Padding(
                              padding: EdgeInsets.only(right: 230, bottom: 8),
                              child: Text(
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                  'Your e-mail'),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 50, left: 50),
                              child: TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    email = value;
                                  });
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    hintText: 'Email',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    prefixIcon: Icon(Icons.mail)),
                              ),
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding: EdgeInsets.only(right: 230, bottom: 8),
                              child: Text(
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                  'Password'),
                            ),
                            Padding(
                                padding: EdgeInsets.only(right: 50, left: 50),
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      password = value;
                                    });
                                  },
                                  obscureText: isClosedeye,
                                  decoration: InputDecoration(suffixIcon: GestureDetector(onTap: () {
                                  setState(() {
                                    if(isClosedeye == true){isClosedeye = false;}
                                    else{isClosedeye = true;}
                                  }
                                  );
                                },child:  Icon(isClosedeye ? Icons.visibility_off : Icons.remove_red_eye),),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      hintText: 'Enter your password',
                                      hintStyle: TextStyle(color: Colors.grey)),
                                )),
                            SizedBox(height: 10),
                            Padding(
                                child: GestureDetector(
                                    child: Text(
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.red),
                                        'Forgot password?'),
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) {
                                          return check();
                                        },
                                      ));
                                    }),
                                padding: EdgeInsets.only(left: 190)),
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
                                    setState(() {
                                      login(email, password);
                                    });
                                  },
                                  child: Text('Sign In')),
                            ),
                          ]),
                    )),
              )),
        ],
      )),
    );
  }

  Future<void> login(String email, String password) async {
    final Map<String, dynamic> loginData = {
      'email': email,
      'password': password,
    };
    final http.Response response = await http.post(
      Uri.parse('http://34.31.110.154/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(loginData),
    );
    
    print('--------------------------------------------------------');
    print(response.statusCode);
    print('--------------------------------------------------------');
    print(response.body);
    
    

    
    if (response.statusCode == 200) {
      Map<String, dynamic> map = json.decode(response.body);
      String? message;

    String? token; 
    setState(() {
      message = map['message'];

    token = map['token'] ?? '';
    });;
    print(message);
      if (message == 'Logged in successfully') {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return HomePage();
          },
        ));
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token!);
      }
     
    }
    else if( response.statusCode == 401){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(backgroundColor: Colors.red,content: Text('Wrong email or password')));
    }
     else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(backgroundColor: Colors.red,content: Text('Connection Error')));
    }
  }
}
