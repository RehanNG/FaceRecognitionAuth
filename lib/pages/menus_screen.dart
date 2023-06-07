import 'package:face_net_authentication/pages/sign-in.dart';
import 'package:face_net_authentication/pages/sign-up.dart';
import 'package:face_net_authentication/pages/user_mgt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';

class MenuItems extends StatefulWidget {
  const MenuItems({Key? key}) : super(key: key);
  @override
  State<MenuItems> createState() => _MenuItemsState();
}

class _MenuItemsState extends State<MenuItems> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16

        ),
        children: [


          CustomCard(

            borderRadius: 30,
            color: Color(0xff9a5aec),
            onTap: () {

              // UserMgtScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserMgtScreen()),
              );

            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(child: Icon(Icons.supervised_user_circle ,color: Colors.white,)),
                Text("user mgt",style: TextStyle(color: Colors.white),)
              ],
            ) ,
          ),



          CustomCard(

            borderRadius: 30,
            color: Color(0xff9a5aec),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignIn()),
              );

            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(child: Icon(Icons.login ,color: Colors.white,)),
                Text("login",style: TextStyle(color: Colors.white),)
              ],
            ) ,
          ),



        ],
      ),
    );
  }
}
