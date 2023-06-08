import 'package:camera/camera.dart';
import 'package:face_net_authentication/pages/sign-in.dart';
import 'package:face_net_authentication/pages/sign-up.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart' as DatePackage;
import 'package:shared_preferences/shared_preferences.dart';

import '../locator.dart';
import '../particle_canvas.dart';
import '../services/camera.service.dart';
import '../services/face_detector_service.dart';
import '../services/ml_service.dart';
import '../services/timedelay_service.dart';
import 'menus_screen.dart';
import 'models/user.model.dart';

//nav imports


/*
usefull info
var date = DateTime.now();
print(date.toString()); // prints something like 2019-12-10 10:02:22.287949
print(DateFormat('EEEE').format(date)); // prints Tuesday
print(DateFormat('EEEE, d MMM, yyyy').format(date)); // prints Tuesday, 10 Dec, 2019
print(DateFormat('h:mm a').format(date)); // prints 10:02 AM



Column

mainAxisAlignment: MainAxisAlignment.center //Center Column contents vertically,
crossAxisAlignment: CrossAxisAlignment.center //Center Column contents horizontally,
Row

mainAxisAlignment: MainAxisAlignment.center //Center Row contents horizontally,
crossAxisAlignment: CrossAxisAlignment.center //Center Row contents vertically,



* */


class timeScreen extends StatefulWidget {
  const timeScreen({Key? key}) : super(key: key);

  @override
  State<timeScreen> createState() => timeScreenState();
}

class timeScreenState extends State<timeScreen> {


  // String formattedDate = DateFormat.yMMMEd().format(DateTime.now());

  static String CurrentMonth_DAY = DatePackage.DateFormat('EEEE').format(DateTime.now());
  int current_hour = DateTime.now().hour;
  int current_minuites = DateTime.now().minute;
  int current_month = DateTime.now().month;
  int current_year = DateTime.now().year;
  int current_day = DateTime.now().day;

 static String checkIn="check in";
  static String checkout="check out";

  void initState(){
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size; // FOR PARTICLE JS
    return  Scaffold(
      // backgroundColor: Color(0xff9d9d9d),
      backgroundColor: Colors.black,

      body: Stack(

        fit: StackFit.expand,
        children: <Widget>[
          // ParticleCanvas(height: size.height, width: size.width),


          Image.asset('assets/particles.jpg', fit: BoxFit.cover),


          Center(

            child: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[



                    Text("$current_hour : $current_minuites" ,style: TextStyle(fontSize: 100, fontWeight: FontWeight.w500, color: Color(
                        0x93000000)),),
                    SizedBox(height: 50),


                        Text("$current_year-$current_month-$current_day", style: TextStyle(fontSize: 30 , fontWeight: FontWeight.w700,color: Color(
                            0x93000000))),
                        SizedBox(height:70),
                        Text("$CurrentMonth_DAY", style: TextStyle(fontSize: 60,fontWeight: FontWeight.w700,color: Color(
                            0x93000000))),




                    SizedBox(height:15),

                    Padding(
                      padding: const EdgeInsets.only(top:20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(onPressed:()async{

                            // Obtain shared preferences.
                            final SharedPreferences prefs = await SharedPreferences.getInstance();

                            // Save an String value to 'action' key.
                            await prefs.setString('checkinaction', '$checkIn');
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn()));
                          }, style: ElevatedButton.styleFrom(primary: Colors.black, onPrimary: Colors.black , alignment: Alignment.centerLeft),child:Text("$checkIn",style:TextStyle(color:Colors.white , fontSize: 20, fontWeight: FontWeight.w700)) ,  ),
                          SizedBox(width:80),


                          ElevatedButton(onPressed:()async{
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setString('checkinaction', '$checkout');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignIn()),
                            );


                          }, style: ElevatedButton.styleFrom(primary: Colors.black, onPrimary: Colors.black , alignment: Alignment.centerRight) ,child:Text("$checkout",style:TextStyle(color:Colors.white , fontSize: 20 , fontWeight: FontWeight.w700)) ),


                        ],
                      ),
                    )
                    ,


                    SizedBox(height: 135),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(onPressed: ()async{


                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MenuItems()),
                          );

                        }, child: Icon(Icons.menu,) ,style:ElevatedButton.styleFrom(

              backgroundColor: Colors.black
              ,shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(350.0),
                          )
                        ),)
                      ],

                    ),

                  ],
                ),
              ),

            ),
          ),
        ],


      ),



    );
  }
}
