import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/home.dart';
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:face_net_authentication/pages/widgets/auth_button.dart';
import 'package:face_net_authentication/pages/widgets/camera_detection_preview.dart';
import 'package:face_net_authentication/pages/widgets/camera_header.dart';
import 'package:face_net_authentication/pages/widgets/signin_form.dart';
import 'package:face_net_authentication/pages/widgets/single_picture.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:face_net_authentication/services/ml_service.dart';
import 'package:face_net_authentication/services/face_detector_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;

import '../services/c_conversion.dart';
class SignIn extends  StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  CameraService _cameraService = locator<CameraService>();
  FaceDetectorService _faceDetectorService = locator<FaceDetectorService>();
  MLService _mlService = locator<MLService>();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isPictureTaken = false;
  bool _isInitializing = false;
  bool present_status = false;

  var date = DateTime.now();
  Future<Database>? _database;
  final ConversionService _conversionService = ConversionService();
  @override
  void initState() {
    super.initState();

    _start();

    _database=initializeDatabase();
    _conversionService.initialize();
  }

  @override
  void dispose() {
    // _cameraService.dispose();
    _mlService.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  Future _start() async {
    setState(() => _isInitializing = true);
    await _cameraService.initialize();
    _faceDetectorService.initialize();
    setState(() => _isInitializing = false);
    _frameFaces();
  }

  Size? imageSize;
  bool _detectingFaces = false;
  Face? faceDetected;


  //orignal
  // _frameFaces() async {
  //   imageSize = _cameraService.getImageSize();
  //   bool _detectingFaces = false;
  //   _cameraService.cameraController!
  //       .startImageStream((CameraImage image) async {
  //
  //         if(_cameraService.cameraController !=null)
  //           {
  //             if(_detectingFaces) return;
  //             _detectingFaces=true;
  //             try{
  //               // var clearFace=image;
  //               await _faceDetectorService.detectFacesFromImage(image);
  //
  //               if(_faceDetectorService.faces.isNotEmpty){
  //                 setState(() {
  //                   faceDetected= _faceDetectorService.faces[0];
  //                 });
  //                 var eulerAngleY = faceDetected!.headEulerAngleY! >10 || faceDetected!.headEulerAngleY! <-10;
  //                 if(!eulerAngleY){
  //                   await _predictFacesFromImage(image: image);
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(builder: (context) => SignIn()),
  //                   );
  //                 }
  //               }
  //
  //               else{
  //                 setState(() {
  //                   _faceDetectorService.initialize();
  //                   faceDetected=null;
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(builder: (context) => SignIn()),
  //                   );
  //                 });
  //                 _detectingFaces=false;
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(builder: (context) => SignIn()),
  //                 );
  //               }
  //
  //             }catch(e){
  //               _faceDetectorService.initialize();
  //               _detectingFaces = false;
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => SignIn()),
  //               );
  //             }
  //           }
  //
  //     // if (processing) return; // prevents unnecessary overprocessing.
  //     // processing = true;
  //     //here marking attendance functionality is done
  //     // await _predictFacesFromImage(image: image);
  //     // processing = true;
  //   });
  //
  //
  // }



  // _frameFaces() async {
  //   imageSize = _cameraService.getImageSize();
  //   _cameraService.cameraController!.startImageStream((CameraImage image) async {
  //     if (_cameraService.cameraController != null) {
  //       if (_detectingFaces) return;
  //       _detectingFaces = true;
  //       try {
  //         await _faceDetectorService.detectFacesFromImage(image);
  //
  //         if (_faceDetectorService.faces.isNotEmpty) {
  //           setState(() {
  //             faceDetected = _faceDetectorService.faces[0];
  //           });
  //           var eulerAngleY =
  //               faceDetected!.headEulerAngleY! > 10 || faceDetected!.headEulerAngleY! < -10;
  //           if (!eulerAngleY) {
  //             await _predictFacesFromImage(image: image);
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => SignIn()),
  //             );
  //           }
  //         } else {
  //           setState(() {
  //             _faceDetectorService.initialize();
  //             faceDetected = null;
  //           });
  //         }
  //       } catch (e) {
  //         _faceDetectorService.initialize();
  //       } finally {
  //         _detectingFaces = false;
  //       }
  //     }
  //   });
  // }

  //this version removes
  _frameFaces() async {
    _cameraService.cameraController!.setFlashMode(FlashMode.torch);
    imageSize = _cameraService.getImageSize();
    if (_cameraService.cameraController != null && !_cameraService.cameraController!.value.isStreamingImages) {
      _cameraService.cameraController!.startImageStream((CameraImage image) async {
        if (_detectingFaces) return;
        _detectingFaces = true;
        try {
          await _faceDetectorService.detectFacesFromImage(image);

          if (_faceDetectorService.faces.isNotEmpty) {
            faceDetected = _faceDetectorService.faces[0];
            var eulerAngleY =
                faceDetected!.headEulerAngleY! > 10 || faceDetected!.headEulerAngleY! < -10;
            if (!eulerAngleY) {
              await _predictFacesFromImage(image: image);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignIn()),
              );
            }
          } else {
            _faceDetectorService.initialize();
            faceDetected = null;
          }
        } finally {
          _detectingFaces = false;
        }
        setState(() {});
      });
    }
  }
  // _frameFaces() async {
  //   imageSize = _cameraService.getImageSize();
  //   if (_cameraService.cameraController != null) {
  //     _cameraService.cameraController!.startImageStream((CameraImage image) async {
  //       if (_detectingFaces) return;
  //       _detectingFaces = true;
  //       try {
  //         await _faceDetectorService.detectFacesFromImage(image);
  //
  //         if (_faceDetectorService.faces.isNotEmpty) {
  //           faceDetected = _faceDetectorService.faces[0];
  //           var eulerAngleY =
  //               faceDetected!.headEulerAngleY! > 10 || faceDetected!.headEulerAngleY! < -10;
  //           if (!eulerAngleY) {
  //             await _predictFacesFromImage(image: image);
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => SignIn()),
  //             );
  //           }
  //         } else {
  //           _faceDetectorService.initialize();
  //           faceDetected = null;
  //         }
  //       } finally {
  //         _detectingFaces = false;
  //       }
  //       setState(() {});
  //     });
  //   }
  // }

bool locked=false;



  Future<void> _predictFacesFromImage({@required CameraImage? image}) async {

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now.toLocal());

if(!locked){

  locked=true;
    var getUser;
    var getId;
    assert(image != null, 'Image is null');
    await _faceDetectorService.detectFacesFromImage(image!);
    //ager face detect ho gya to kia kam kro
    if (_faceDetectorService.faceDetected) {
      try {
        //null exception error a reha ha , , user jab present nai ha to values null hain , users jab detect ho ga tabhe value aye ge
        //Null check operator used on a null value


        _mlService.setCurrentPrediction(image, _faceDetectorService.faces[0]);
        //  start from here
        //  capture face
        await _cameraService.takePicture();
        setState(() => _isPictureTaken = true);
        //  capture user
        User? user = await _mlService.predict();

        if (user != null) {
          getUser = user.user;
          print(getUser);
          //  capture password/id
          getId = user.password;
          // var getId = user.password;
          print(getId);

        var cameraService = _cameraService.imagePath.toString();
        var imagetoSend = base64Image(cameraService);
        print(imagetoSend);
        //attendance stats
        present_status = true;
        String pre_stat_conv = present_status.toString();
        //  mark attendance
        insertRegistered(
            getUser, getId, imagetoSend, pre_stat_conv, date.toString());
        //show toast
        Fluttertoast.showToast(
            msg: " user: $getUser --- Id: $getId --- present : $present_status ",
            backgroundColor: Colors.green,
            gravity: ToastGravity.CENTER,
        toastLength:Toast.LENGTH_SHORT,
        ) ;
        _faceDetectorService.initialize();
        //
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );

        }
        else if( user != null &&  (date.minute==date.minute) ){
          Fluttertoast.showToast(
            msg: " duplicate punch ",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER,
            toastLength:Toast.LENGTH_SHORT,
          );
        }


      } catch (e) {
        print("catch kia hua exception   $e");
      }


      //  refresh screen


      //else  main jane sa pehla error da reha ha yane if ke condition main phat reha ha

    }

    else if(!_faceDetectorService.faceDetected){
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(content: Text('No face detected!')));
    }

    else {
      _faceDetectorService.initialize();
      print("present in else");
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(content: Text('No face detected!')));
    }
    if (!mounted) {
      return;
    }
    // if (mounted) setState(() {});

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => MyHomePage()),
    // );

  }

  }

  String convertCameraImageToBase64(CameraImage image) {
    // Convert the image to a Uint8List
    final Uint8List bytes = Uint8List.view(image.planes[0].bytes.buffer);

    // Encode the bytes to base64
    final String base64Image = base64Encode(bytes);

    return base64Image;
  }


  //attenance markind
  Future<void>createRegisteredTable(Database db,int version) async {
    await db.execute('''
    CREATE TABLE userattendance (
    id INTEGER PRIMARY KEY,
    username TEXT,
    userId TEXT,
    image TEXT,
    presentstat TEXT,
    attendancetime TEXT
    )
    ''');
  }

  Future<Database> initializeDatabase() async{
    final databasePath = await getDatabasesPath();
    final path = Path.join(databasePath,'attendancedatabase.db');
    return openDatabase(path,
        version: 1,
        onCreate: (db,version) async {
          await createRegisteredTable(db, version);
        }
    );
  }

  Future<void> insertRegistered(String username , String userId,String image , String presentstat , String attendancetime)
  async{
    final db= await _database;

    await db!.insert('userattendance', {

      'username':username,
      'userId':userId,
      'image':image,
      'presentstat':presentstat,
      'attendancetime':attendancetime,
    });
  }

  String base64Image(String imagePath) {
    File imageFile = File(imagePath);
    List<int> imageBytes = imageFile.readAsBytesSync();
    return base64Encode(imageBytes);
  }
  //attenance markind ends


  Future<void> takePicture() async {
    if (_faceDetectorService.faceDetected) {
      await _cameraService.takePicture();
      setState(() => _isPictureTaken = true);
    } else {
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(content: Text('No face detected!')));
    }
  }

  _onBackPressed() {
    // Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );

  }

  _reload() {
    if (mounted) setState(() => _isPictureTaken = false);
    _start();
  }

  //capture pa clik krne k bad
  Future<void> onTap() async {
    //taking picture
    await takePicture();
    //face detect open krna k bad bottom sheet open kro

    if (_faceDetectorService.faceDetected) {
      User? user = await _mlService.predict();

      var bottomSheetController = scaffoldKey.currentState!
          .showBottomSheet((context) => signInSheet(user: user));
      bottomSheetController.closed.whenComplete(_reload);
    }

  }

  Widget getBodyWidget() {
    if (_isInitializing) return Center(child: CircularProgressIndicator());
    if (_isPictureTaken)
      return SinglePicture(imagePath: _cameraService.imagePath!);
    return CameraDetectionPreview();
  }

  @override
  Widget build(BuildContext context) {
    Widget header = CameraHeader("LOGIN", onBackPressed: _onBackPressed);
    Widget body = getBodyWidget();
    Widget? fab;
    if (!_isPictureTaken) fab = AuthButton(onTap: onTap);

    return WillPopScope(
      onWillPop: () async {return false;} ,
      child: Scaffold(
        key: scaffoldKey,
        body: Stack(
          children: [body, header],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: fab,
      ),
    );
  }




  signInSheet({@required User? user}) => user == null
      ? Container(
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.all(20),
    child: Text(
      'User not found 😞',
      style: TextStyle(fontSize: 20),
    ),
  )
      : SignInSheet(user: user);

  //for back


}
