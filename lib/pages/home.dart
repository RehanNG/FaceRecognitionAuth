import 'package:face_net_authentication/constants/constants.dart';
import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/db/databse_helper.dart';
import 'package:face_net_authentication/pages/sign-in.dart';
import 'package:face_net_authentication/pages/sign-up.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:face_net_authentication/services/ml_service.dart';
import 'package:face_net_authentication/services/face_detector_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

import '../particle_canvas.dart';
import '../services/timedelay_service.dart';
import 'time_screen.dart';
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MLService _mlService = locator<MLService>();
  FaceDetectorService _mlKitService = locator<FaceDetectorService>();
  CameraService _cameraService = locator<CameraService>();
  bool loading = false;

  @override
  void initState(){
    super.initState();
    _initializeServices();
    delayTimerForPageNavigation(5,context,timeScreen());
  }

  _initializeServices() async {
    setState(() => loading = true);
    await _cameraService.initialize();
    await _mlService.initialize();
    _mlKitService.initialize();
    setState(() => loading = false);
  }

  void _launchURL() async => await canLaunch(Constants.githubURL)
      ? await launch(Constants.githubURL)
      : throw 'Could not launch ${Constants.githubURL}';

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size; // FOR PARTICLE JS

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.indigoAccent,
        appBar: AppBar(
          leading: Container(),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: <Widget>[

          ],
        ),
        body: !loading
            ? SingleChildScrollView(
                child: SafeArea(
                  child:  Padding(
                    padding: const EdgeInsets.only(top: 250, left: 20, right: 20),
                    child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image(image: AssetImage('assets/logo.png')),
                              // Column(
                              //   children: [
                              //     InkWell(
                              //       onTap: () {
                              //         Navigator.push(
                              //           context,
                              //           MaterialPageRoute(
                              //             builder: (BuildContext context) => SignIn(),
                              //           ),
                              //         );
                              //       },
                              //       child: Container(
                              //         decoration: BoxDecoration(
                              //           borderRadius: BorderRadius.circular(10),
                              //           color: Colors.white,
                              //           boxShadow: <BoxShadow>[
                              //             BoxShadow(
                              //               color: Colors.blue.withOpacity(0.1),
                              //               blurRadius: 1,
                              //               offset: Offset(0, 2),
                              //             ),
                              //           ],
                              //         ),
                              //         alignment: Alignment.center,
                              //         padding: EdgeInsets.symmetric(
                              //             vertical: 14, horizontal: 16),
                              //         width: MediaQuery.of(context).size.width * 0.8,
                              //         child: Row(
                              //           mainAxisAlignment: MainAxisAlignment.center,
                              //           children: [
                              //             Text(
                              //               'LOGIN',
                              //               style: TextStyle(color: Color(0xFF0F0BDB)),
                              //             ),
                              //             SizedBox(
                              //               width: 10,
                              //             ),
                              //             Icon(Icons.login, color: Color(0xFF0F0BDB))
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //     SizedBox(
                              //       height: 10,
                              //     ),
                              //     InkWell(
                              //       onTap: () {
                              //         Navigator.push(
                              //           context,
                              //           MaterialPageRoute(
                              //             builder: (BuildContext context) => SignUp(),
                              //           ),
                              //         );
                              //       },
                              //       child: Container(
                              //         decoration: BoxDecoration(
                              //           borderRadius: BorderRadius.circular(10),
                              //           color: Color(0xFF0F0BDB),
                              //           boxShadow: <BoxShadow>[
                              //             BoxShadow(
                              //               color: Colors.blue.withOpacity(0.1),
                              //               blurRadius: 1,
                              //               offset: Offset(0, 2),
                              //             ),
                              //           ],
                              //         ),
                              //         alignment: Alignment.center,
                              //         padding: EdgeInsets.symmetric(
                              //             vertical: 14, horizontal: 16),
                              //         width: MediaQuery.of(context).size.width * 0.8,
                              //         child: Row(
                              //           mainAxisAlignment: MainAxisAlignment.center,
                              //           children: [
                              //             Text(
                              //               'SIGN UP',
                              //               style: TextStyle(color: Colors.white),
                              //             ),
                              //             SizedBox(
                              //               width: 10,
                              //             ),
                              //             Icon(Icons.person_add, color: Colors.white)
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //     SizedBox(
                              //       height: 20,
                              //       width: MediaQuery.of(context).size.width * 0.8,
                              //       child: Divider(
                              //         thickness: 2,
                              //       ),
                              //     ),
                              //   ],
                              // )
                            ],


                      ),
                  ),






                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
