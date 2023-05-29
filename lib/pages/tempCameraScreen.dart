import 'dart:core';

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:face_net_authentication/main.dart';
import 'package:face_net_authentication/pages/sign-in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class TempCameraScreen extends StatefulWidget {

  @override
  State<TempCameraScreen> createState() => _CameraScreenState();
}
class _CameraScreenState extends State<TempCameraScreen> with WidgetsBindingObserver {
  //Camera is initializing here
  void initState() {


  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      body: Container(
        
      ),

    );
  }

  Future<void> _delay(int time){

    return Future.delayed(Duration(seconds: time));
  }
}


