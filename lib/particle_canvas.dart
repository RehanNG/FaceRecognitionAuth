import 'dart:math';

import 'package:flutter/material.dart';

class ParticleCanvas extends StatefulWidget {
  const ParticleCanvas({Key? key, required this.height, required this.width}) : super(key: key);

  final double height;
  final double width;

  @override
  _ParticleCanvasState createState() => _ParticleCanvasState();
}

class _ParticleCanvasState extends State<ParticleCanvas>
    with TickerProviderStateMixin {
  Animation<double>? animation;
  List<Offset> dots = [];
  List<List> lines = [];
  AnimationController? controller, mouseController;
  Duration mouseDuration = Duration(milliseconds: 600);
  var random = Random();
  List<bool> rndDirection = [];
  List<double> rndPos = [];
  double? speed = 0.1, temp = 0, dx, dy, mradius = 60;
  int totalDots = 70;

  @override
  void dispose() {
    controller!.dispose();
    mouseController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    addDots();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10));
    animation = Tween<double>(begin: 0, end: 1).animate(controller!)
      ..addListener(() {
        setState(() {
          speed = speed;
          for (var i = 0; i < dots.length; i++) {
            if (rndDirection[i]) {
              temp = -speed!;
            } else {
              temp = speed;
            }
            dx = dots[i].dx + (temp! * rndPos[i]);
            dy = dots[i].dy + rndPos[i] * speed!;
            if (dx! > widget.width) {
              dx = (dx! - widget.width)!;
            } else if (dx! < 0) {
              dx = dx! + widget.width;
            }
            if (dy! > widget.height) {
              dy = dy! - widget.height;
            } else if (dy! < 0) {
              dy = dy! + widget.height;
            }
            dots[i] = Offset(dx!, dy!);
          }
          drawlines();
        });
      });
    controller!.repeat();
    changeDirection();
    super.initState();
  }

  addDots() {
    for (var i = 0; i < totalDots; i++) {
      dots.add(Offset(random.nextDouble() * widget.width,
          random.nextDouble() * widget.height));
      rndPos.add(random.nextDouble());
      rndDirection.add(random.nextBool());
    }
  }

  drawlines() {
    lines = [];
    var distanceToDrawLine = 0.0;
    for (var i = 0; i < dots.length; i++) {
      for (var j = 0; j < dots.length; j++) {
        distanceToDrawLine = sqrt(aMinusBSquare(dots[j].dx, dots[i].dx) +
            aMinusBSquare(dots[j].dy, dots[i].dy));
        if (distanceToDrawLine < 50) {
          lines.add([dots[i], dots[j], distanceToDrawLine]);
        }
      }
    }
  }

  aMinusBSquare(a, b) {
    return pow((a - b), 2);
  }

  onHover(dx, dy) {
    mouseController = AnimationController(vsync: this, duration: mouseDuration);
    mouseController!.reset();
    double mdx, mdy;
    var stopDistance = 60.0;
    mouseController!.forward();
    for (var i = 0; i < dots.length; i++) {
      stopDistance =
          sqrt(aMinusBSquare(dx, dots[i].dx) + aMinusBSquare(dy, dots[i].dy));
      mdx = (dx - dots[i].dx) / stopDistance;
      mdy = (dy - dots[i].dy) / stopDistance;
      if (stopDistance < mradius!) {
        var x = dots[i].dx - (mradius! - stopDistance) * mdx;
        var y = dots[i].dy - (mradius! - stopDistance) * mdy;
        setState(() {
          dots[i] = Offset(x, y);
        });
      }
    }
  }

  void changeDirection() async {
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 500));
      for (var i = 0; i < totalDots; i++) {
        rndDirection[i] = random.nextBool();
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) {
        onHover(e.localPosition.dx, e.localPosition.dy);
      },
      child: Container(
        height: widget.height,
        width: widget.width,
        child: CustomPaint(
          painter: DotsPainter(dots: dots, lines: lines),
        ),
      ),
    );
  }
}

class DotsPainter extends CustomPainter {
  DotsPainter({required this.lines, required this.dots});
/*
To increase the size of the dots in the `ParticleCanvas` widget,
you can modify the `sizes` list in the `DotsPainter` class. Currently,
the `sizes` list contains three values `[1, 2, 3]` which are randomly selected
to draw the dots.
You can change these values to increase the size of the dots.


For example, if you want to increase the size of the dots to a fixed value of `5`, you can modify the `sizes` list as follows:
List<double> sizes = [5];


If you want to randomly select a size between a range, you can modify the `sizes` list as follows:
List<double> sizes = [3, 4, 5];

* */
  final List<Offset> dots;
  final List<List> lines;
  List<double> sizes = [1, 2, 3];
  // List<double> sizes = [2, 4, 5,8];

  var random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < dots.length; i++) {
      canvas.drawCircle(
          dots[i], sizes[random.nextInt(2)], Paint()..color = Colors.grey);
    }
    lines.forEach((element){
      var paint = Paint()
        ..color = Colors.grey
        ..strokeWidth = 2.0 * (1 - element[2] / 50);
      canvas.drawLine(element[0], element[1], paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}