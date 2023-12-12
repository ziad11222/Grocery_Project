import 'package:flutter/material.dart';
import 'main.dart';
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: signup(),
  ));
}

class signup extends StatefulWidget {
  const signup({Key? key}) : super(key: key);

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  GlobalKey<FormState> KEY = GlobalKey<FormState>();
  var name;
  var PhoneNumber;
  var email;
  var password;
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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
                  child: Container(margin: EdgeInsets.only(top: 35),
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
                  flex: 4,
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
                                    'Create an account.'),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        style: TextStyle(color: Colors.grey),
                                        "Already a member?"),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) {
                                              return loginpage();
                                            }));
                                      },
                                      child: Text(
                                          style:
                                          TextStyle(color: Colors.greenAccent),
                                          'Sign in'),
                                    )
                                  ],
                                ),
                                SizedBox(height: 20), Padding(
                                  padding: EdgeInsets.only(right: 210, bottom: 8),
                                  child: Text(
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                      'Your full name'),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(right: 50, left: 50),
                                  child: TextFormField(onChanged: (value){
                                    setState(() {
                                      name = value;
                                    });
                                  },
                                    validator: (value) {
                                      if (value!.length < 6) {
                                        return 'Enter your full name';
                                      }
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                      hintText: 'Name',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),SizedBox(height: 10,), Padding(
                                  padding: EdgeInsets.only(right: 210, bottom: 8),
                                  child: Text(
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                      'Birth Date'),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(right: 50, left: 50),
                                  child: TextFormField(onChanged: (value){
                                    setState(() {
                                      PhoneNumber= value;
                                    });
                                  },
                                   
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                      hintText: 'b-date',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),SizedBox(height: 10,),
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
                                  child: TextFormField(onChanged: (value){
                                    setState(() {
                                      email= value;
                                    });
                                  },
                                    validator: (value) {
                                      if (value!.length < 6) {
                                        return 'Enter a valid Email';
                                      }
                                    },
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(10)),
                                        hintText: 'Email',
                                        hintStyle: TextStyle(color: Colors.grey),
                                        prefixIcon: Icon(Icons.mail)),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: EdgeInsets.only(right: 230, bottom: 8),
                                  child: Text(
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                      'Password'),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(right: 50, left: 50),
                                    child: TextFormField(onChanged: (value){
                                      password = value;
                                    },
                                      controller: passwordController,
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
                                          hintText: 'Enter your password',
                                          hintStyle: TextStyle(color: Colors.grey)),
                                    )),
                                SizedBox(height: 10),
                                Padding(
                                  padding: EdgeInsets.only(right: 230, bottom: 8),
                                  child: Text(
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                      'Address'),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(right: 50, left: 50),
                                    child: TextFormField(
                                      
                                      
                                     
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(10)),
                                          hintText: 'Address',
                                          hintStyle: TextStyle(color: Colors.grey)),
                                    )),
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

                                      },
                                      child: Text('Sign Up')),
                                ),
                              ]),
                        )),
                  )),
            ],
          )),
    );
  }

}

