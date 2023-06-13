import 'package:flutter/material.dart';

import 'get_all_users.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: <Widget>[

            //new user
            Row(
              children: <Widget>[
                // IconButton(style: IconButton.styleFrom(shape: RoundedRectangleBorder(side: )) , onPressed: (){
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) => const SignUp()),
                //   );
                //   // SignUpState.cameraService.cameraController!.resumePreview();
                //
                //
                // }, icon:Icon(Icons.person_add)),




                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.indigoAccent, //<-- SEE HERE
                  child: IconButton(
                    icon: Icon(
                      Icons.person_add,
                      color: Colors.white,
                    ),
                    onPressed: () {

                      Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUp()),
                            );
                            // SignUpState.cameraService.cameraController!.resumePreview();



                    },
                  ),
                ),


                SizedBox(width: 20),
                Text("New user"),
              ],
            ),

          SizedBox(height: 20),
          //  all users
            Row(
              children: <Widget>[

                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.indigoAccent, //<-- SEE HERE
                  child: IconButton(
                    icon: Icon(
                      Icons.supervised_user_circle_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GettingAllUsersFromDataBase()),
                      );
                      SignUpState.cameraService.cameraController!.resumePreview();



                    },
                  ),
                ),
                SizedBox(width: 20),
                Text("All user"),
              ],

            ),


          ],
        ),
      ),
    );
  }
}
