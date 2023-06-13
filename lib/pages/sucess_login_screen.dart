import 'package:face_net_authentication/services/timedelay_service.dart';
import 'package:flutter/material.dart';
import 'time_screen.dart';
class SucessScreen extends StatefulWidget {
  const SucessScreen({Key? key}) : super(key: key);

  @override
  State<SucessScreen> createState() => _SucessScreenState();
}



class _SucessScreenState extends State<SucessScreen> {

  @override
  void initState(){
    super.initState();
    delayTimerForPageNavigation(5,context,timeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                Text("Sucess"),
                Icon(Icons.check_circle ,color: Colors.green)

              ],
            ),
          )
        ),
      ),
    );
  }



}
