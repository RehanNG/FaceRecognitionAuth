
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
delayTimerForPageNavigation(int duration_in_numbers  , dynamic context, dynamic route){


  Future.delayed(Duration(seconds: duration_in_numbers), () {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  route),
    );
  });




}

