import 'package:flutter/material.dart';
import 'package:grocery_app/profile.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'home.dart';
import 'cart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PersistentTabController? controller;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Column(
          children: [
            Flexible(
              child: Stack(
                children: [
                  PersistentTabView(context,
                      confineInSafeArea: true,
                      backgroundColor: Colors.white,
                      handleAndroidBackButtonPress: true,
                      resizeToAvoidBottomInset: true,
                      decoration: NavBarDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        colorBehindNavBar: Colors.white,
                      ),
                      controller: controller,
                      items: [
                        PersistentBottomNavBarItem(
                          textStyle: TextStyle(color: Color(0xFFB8B8D2)),
                          activeColorPrimary: Colors.green,
                          activeColorSecondary: Colors.black,
                          title: 'Home',
                          icon: Icon(Icons.home_filled),
                        ),
                        PersistentBottomNavBarItem(
                          textStyle: TextStyle(color: Color(0xFFB8B8D2)),
                          title: 'Course',
                          activeColorPrimary: Colors.green,
                          activeColorSecondary: Colors.black,
                          icon: Icon(Icons.book),
                        ),
                       
                        PersistentBottomNavBarItem(
                            textStyle: TextStyle(color: Color(0xFFB8B8D2)),
                            title: 'Account',
                            activeColorPrimary: Colors.green,
                            activeColorSecondary: Colors.black,
                            icon: Icon(Icons.person))
                      ],
                      navBarStyle: NavBarStyle.style12,
                      screens: _widgetOptions),
                ],
              ),
            ),],
        ),
      ),
    );
  }
  List<Widget> _widgetOptions = <Widget>[
    home(),cart(),profile()
   
  ];
}
