import 'package:flutter/material.dart';

import 'sign-up.dart';
class UserMgtScreen extends StatefulWidget {
  const UserMgtScreen({Key? key}) : super(key: key);

  @override
  State<UserMgtScreen> createState() => _UserMgtScreenState();
}

class _UserMgtScreenState extends State<UserMgtScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[

          //new user
          Row(
            children: <Widget>[
              IconButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUp()),
                );
                // SignUpState.cameraService.cameraController!.resumePreview();


              }, icon:Icon(Icons.person_add)),
              Text("New user"),
            ],
          ),

        //  all users
          Row(
            children: <Widget>[
              IconButton(onPressed: (){}, icon:Icon(Icons.supervised_user_circle_rounded)),
              Text("All user"),
            ],

          ),


        ],
      ),
    );
  }
}
