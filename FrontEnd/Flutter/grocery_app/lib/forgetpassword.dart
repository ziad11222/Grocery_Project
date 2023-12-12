import 'package:flutter/material.dart';
import 'signup.dart';
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
                                onTap: () {  Navigator.push(context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return signup();
                                      },
                                    ));},
                                child: Text(
                                    style: TextStyle(decoration: TextDecoration.underline,
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
}
