import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/widgets/FacePainter.dart';
import 'package:face_net_authentication/pages/widgets/auth-action-button.dart';
import 'package:face_net_authentication/pages/widgets/camera_header.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:face_net_authentication/services/ml_service.dart';
import 'package:face_net_authentication/services/face_detector_service.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;

import '../services/timedelay_service.dart';
import 'menus_screen.dart';
class SignUp extends StatefulWidget  {
  const SignUp({Key? key}) : super(key: key);

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> with WidgetsBindingObserver{

 static String? imagePath; //Image path for base64 conversion
  Face? faceDetected;
  Size? imageSize;

  static Future<Database>? _database;
  bool _detectingFaces = false;
  bool pictureTaken = false;

  bool _initializing = false;

  bool _saving = false;
  bool _bottomSheetVisible = false;

  static String? pathCapture;

  // service injection
  FaceDetectorService _faceDetectorService = locator<FaceDetectorService>();
  static CameraService cameraService = locator<CameraService>();
  MLService _mlService = locator<MLService>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this );
    super.initState();
    _start();
    _database=initializeDatabase();
  }
static Future<void> createRegisteredTable(Database db , int version) async{
    await db.execute('''
    CREATE TABLE registered (
    id INTEGER PRIMARY KEY,
    username TEXT,
    userId TEXT,
    image TEXT
    )
    ''');
}

static Future<Database> initializeDatabase() async{
    final databasePath = await getDatabasesPath();
    final path = Path.join(databasePath,'my_database.db');
    return openDatabase(
        path,
        version: 1,
        onCreate:(db,version)async{
          await createRegisteredTable(db, version);
        }
    );

}

static Future<void> insertRegistered(String username, String userId, String image) async{
    final db = await _database;
    await db!.insert('registered', {
      'username':username,
      'userId':userId,
      'image':image,
    });
}




  @override
  void dispose() {
    super.dispose();
    // cameraService.dispose();

  }
 @override
 void didChangeAppLifecycleState(AppLifecycleState state) {
//start from here https://www.youtube.com/watch?v=a0RG0sxfSjk

 /*
 _start() async {
    setState(() => _initializing = true);
    await cameraService.initialize();
    setState(() => _initializing = false);

    _frameFaces();
  }
 * */


   if(state == AppLifecycleState.resumed)
   {
     print("resumed");
     _detectingFaces=true;
     pictureTaken=true;
     _initializing=true;
     _saving=true;
      cameraService.initialize();
      _frameFaces();
   }
   else if(state==AppLifecycleState.inactive){
     print("inactive");
     _detectingFaces=false;
     pictureTaken=false;
     _initializing=false;
     _saving=false;
     // cameraService.cameraController!.stopImageStream();
   }
   else if(state == AppLifecycleState.detached){
     print("Detached");
   }
   else if(state == AppLifecycleState.paused){
     print("Paused");
     _detectingFaces=false;
     pictureTaken=false;
     _initializing=false;
     _saving=false;
     // cameraService.cameraController!.stopImageStream();
   }



 }


  _start() async {
    setState(() => _initializing = true);
    await cameraService.initialize();
    setState(() => _initializing = false);

    _frameFaces();
  }

  Future<bool> onShot() async {
    if (faceDetected == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('No face detected!'),
          );
        },
      );

      return false;
    } else {
      //capturing picture
      _saving = true;
      await Future.delayed(Duration(milliseconds: 500));
      // await _cameraService.cameraController?.stopImageStream();
      await Future.delayed(Duration(milliseconds: 200));
      File file = await cameraService.takePicture();
      //this is my image path that needed to be converted to base64
      imagePath = file?.path;
      //using in insertRegistered
      pathCapture=file?.path;

      setState(() {
        _bottomSheetVisible = true;
        pictureTaken = true;
      });

      return true;
    }
  }

  _frameFaces() {
    imageSize = cameraService.getImageSize();

    cameraService.cameraController?.startImageStream((image) async {


      if (cameraService.cameraController != null) {
        if (_detectingFaces) return;

        _detectingFaces = true;

        try {
          await _faceDetectorService.detectFacesFromImage(image);

          if (_faceDetectorService.faces.isNotEmpty) {

            setState(() {
              //front face
              faceDetected = _faceDetectorService.faces[0];
            });
            if (_saving) {
              _mlService.setCurrentPrediction(image, faceDetected);
              setState(() {
                _saving = false;
              });
            }


          }
          // else if(cameraService.cameraController !=null && cameraService.cameraController!.value.isPreviewPaused){cameraService.cameraController!.resumePreview();   delayTimerForPageNavigation(0,context,SignUp());}

          else {
            print('face is null');
            setState(() {
              faceDetected = null;
            });

            // delayTimerForPageNavigation(3,context,MenuItems());




          }


          _detectingFaces = false;
        } catch (e) {
          print('Error _faceDetectorService face => $e');
          _detectingFaces = false;
        }
      }
    });
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  _reload() {
    setState(() {
      _bottomSheetVisible = false;
      pictureTaken = false;
    });
    this._start();
  }

  @override
  Widget build(BuildContext context) {
    final double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    late Widget body;
    if (_initializing) {
      body = Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_initializing && pictureTaken) {
      body = Container(
        width: width,
        height: height,
        child: Transform(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.file(File(imagePath!)),
            ),
            transform: Matrix4.rotationY(mirror)),
      );
    }

    if (!_initializing && !pictureTaken) {
      body = Transform.scale(
        scale: 1.0,
        child: AspectRatio(
          aspectRatio: MediaQuery.of(context).size.aspectRatio,
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Container(
                width: width,
                height:
                    width * cameraService.cameraController!.value.aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CameraPreview(cameraService.cameraController!),
                    CustomPaint(
                      painter: FacePainter(
                          face: faceDetected, imageSize: imageSize!),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
        body: Stack(
          children: [
            body,
            CameraHeader(
              "SIGN UP",
              onBackPressed: _onBackPressed,
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: !_bottomSheetVisible
            ? AuthActionButton(

                onPressed: onShot,
                isLogin: false,
                reload: _reload,
              )
            : Container());
  }


}
