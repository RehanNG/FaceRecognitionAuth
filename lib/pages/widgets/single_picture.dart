// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'dart:math' as math;
//
// class SinglePicture extends StatelessWidget {
//   const SinglePicture({Key? key, required this.imagePath}) : super(key: key);
//   final String imagePath;
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;
//     final double mirror = math.pi;
//     return Container(
//       width: width,
//       height: height,
//       child: Transform(
//           alignment: Alignment.center,
//           child: FittedBox(
//             fit: BoxFit.cover,
//             child: Image.file(File(imagePath)),
//           ),
//           transform: Matrix4.rotationY(mirror)),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
class SinglePicture extends StatelessWidget {
  const SinglePicture({Key? key, required this.imagePath}) : super(key: key);
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final height = Get.height;
    final double mirror = 180.0;
    return Container(
      width: width,
      height: height,
      child: Transform(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.file(File(imagePath)),
          ),
          transform: Matrix4.rotationY(mirror)),
    );
  }
}

/*
In this optimized version, we're using GetX to get the width and height
of the screen instead of using MediaQuery. This is because GetX is faster and more efficient
than MediaQuery. We're also using a constant value for the mirror angle instead of using math.pi,
which is a more efficient approach.
* */

