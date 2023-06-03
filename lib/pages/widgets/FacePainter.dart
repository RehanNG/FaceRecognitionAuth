import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//no error here
class FacePainter extends CustomPainter {
  FacePainter({required this.imageSize, required this.face});
  final Size imageSize;
  double? scaleX, scaleY;
  Face? face;
  @override
  void paint(Canvas canvas, Size size) {
    if (face == null) return;
    Paint paint;
    var eulerAngleY =
        face!.headEulerAngleY! > 10 || face!.headEulerAngleY! < -10;
    if (eulerAngleY) {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Colors.red;
    } else {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Colors.green;
    }

    scaleX = size.width / imageSize.width;
    scaleY = size.height / imageSize.height;

    canvas.drawRRect(
        _scaleRect(
            rect: face!.boundingBox,
            imageSize: imageSize,
            widgetSize: size,
            scaleX: scaleX ?? 1,
            scaleY: scaleY ?? 1),
        paint);
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.face != face;
  }
}

RRect _scaleRect(
    {required Rect rect,
      required Size imageSize,
      required Size widgetSize,
      double scaleX = 1,
      double scaleY = 1}) {
  return RRect.fromLTRBR(
      (widgetSize.width - rect.left.toDouble() * scaleX),
      rect.top.toDouble() * scaleY,
      widgetSize.width - rect.right.toDouble() * scaleX,
      rect.bottom.toDouble() * scaleY,
      const Radius.circular(10));
}



// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class FacePainterController extends GetxController {
//   final imageSize = Rx<Size>(Size.zero);
//   final scaleX = Rx<double?>(null);
//   final scaleY = Rx<double?>(null);
//   final face = Rx<Face?>(null);
//
//   void paint(Canvas canvas, Size size) {
//     if (face.value == null) return;
//
//     Paint paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.0
//       ..color = Colors.green;
//
//     scaleX.value = size.width / imageSize.value.width;
//     scaleY.value = size.height / imageSize.value.height;
//
//     canvas.drawRRect(
//         _scaleRect(
//             rect: face.value!.boundingBox,
//             imageSize: imageSize.value,
//             widgetSize: size,
//             scaleX: scaleX.value ?? 1,
//             scaleY: scaleY.value ?? 1),
//         paint);
//   }
//
//   RRect _scaleRect(
//       {required Rect rect,
//         required Size imageSize,
//         required Size widgetSize,
//         double scaleX = 1,
//         double scaleY = 1}) {
//     return RRect.fromLTRBR(
//       (widgetSize.width - rect.left.toDouble() * scaleX),
//       rect.top.toDouble() * scaleY,
//       widgetSize.width - rect.right.toDouble() * scaleX,
//       rect.bottom.toDouble() * scaleY,
//       Radius.circular(5),
//     );
//   }
// }
//
// class FacePainter extends StatelessWidget {
//   final FacePainterController controller = Get.put(FacePainterController());
//
//   FacePainter({required this.imageSize, required this.face});
//
//   final Size imageSize;
//   final Face? face;
//
//   @override
//   Widget build(BuildContext context) {
//     controller.imageSize.value = imageSize;
//     controller.face.value = face;
//
//     return CustomPaint(
//       painter: _FacePainterPainter(controller),
//     );
//   }
// }
//
// class _FacePainterPainter extends CustomPainter {
//   final FacePainterController controller;
//
//   _FacePainterPainter(this.controller);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     controller.paint(canvas, size);
//   }
//
//   @override
//   bool shouldRepaint(_FacePainterPainter oldDelegate) {
//     return true;
//   }
// }