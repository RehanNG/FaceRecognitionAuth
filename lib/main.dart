import 'package:camera/camera.dart';
import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/home.dart';
import 'package:flutter/material.dart';

void main() async{
  setupServices();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static List<CameraDescription> cameras = [];

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,

      ),
      home: MyHomePage(),
    );
  }
}
