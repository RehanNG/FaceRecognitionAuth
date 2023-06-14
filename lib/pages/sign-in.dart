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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;

import '../services/c_conversion.dart';
import '../services/timedelay_service.dart';
import 'sign-up.dart';
import 'sucess_login_screen.dart';
import 'time_screen.dart';
import 'dart:async';

import 'time_screen.dart';
import 'package:audioplayers/audioplayers.dart';
class SignIn extends  StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  static CameraService cameraService = locator<CameraService>();
  FaceDetectorService _faceDetectorService = locator<FaceDetectorService>();
  MLService _mlService = locator<MLService>();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isPictureTaken = false;
  bool _isInitializing = false;
  bool present_status = false;

  var date = DateTime.now();
  static Future<Database>? database;
  final ConversionService _conversionService = ConversionService();
  @override
  void initState() {
    super.initState();
    _start();

    database=initializeDatabase();
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
    await cameraService.initialize();
    _faceDetectorService.initialize();
    setState(() => _isInitializing = false);
    _frameFaces();
  }

  Size? imageSize;
  bool _detectingFaces = false;
  Face? faceDetected;


  //this version removes
  _frameFaces() async {
    // _cameraService.cameraController!.setFlashMode(FlashMode.torch);
    imageSize = cameraService.getImageSize();
    if (cameraService.cameraController != null && !cameraService.cameraController!.value.isStreamingImages) {

      cameraService.cameraController!.startImageStream((CameraImage image) async {
        if (_detectingFaces) return;
        _detectingFaces = true;
        try {
          await _faceDetectorService.detectFacesFromImage(image);

          if (_faceDetectorService.faces.isNotEmpty) {
            // cameraService.cameraController!.resumePreview();
            faceDetected = _faceDetectorService.faces[0];
            var eulerAngleY =
                faceDetected!.headEulerAngleY! > 10 || faceDetected!.headEulerAngleY! < -10;
            if (!eulerAngleY) {
              await _predictFacesFromImage(image: image);
              // delayTimerForPageNavigation(4 ,context,SignIn());
            }
          }
          else {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => timeScreen()),
            // );

            //ager face detect na ho to date and time wale screen a gye


            // Timer(Duration(seconds: 5), () {
            //   _cameraService.cameraController!.stopImageStream();
            // });
            //   cameraService.cameraController!.pausePreview();


            // _faceDetectorService.initialize();
            // faceDetected = null;
            // _detectingFaces = false;




            // Future.delayed(Duration(seconds: 10), () {
            //
            //   _cameraService.cameraController!.stopImageStream();
            // });



          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => timeScreen()),
          );

        } finally {
          _detectingFaces = false;
        }
        setState(() {});
      });
    }
  }
bool locked=false;



  Future<void> _predictFacesFromImage({@required CameraImage? image}) async {

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now.toLocal());

if(!locked){

  locked=true;
    var getUser;
    var getId;
    assert(image != null, 'Image is null');
    // await _faceDetectorService.detectFacesFromImage(image!);
     _faceDetectorService.detectFacesFromImage(image!);
    //ager face detect ho gya to kia kam kro
    if (_faceDetectorService.faceDetected) {
      try {
        //null exception error a reha ha , , user jab present nai ha to values null hain , users jab detect ho ga tabhe value aye ge
        //Null check operator used on a null value
        _mlService.setCurrentPrediction(image, _faceDetectorService.faces[0]);
        //  start from here
        //  capture face
        await cameraService.takePicture();
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

        var cameraServiceVar = cameraService.imagePath.toString();
        var imagetoSend = base64Image(cameraServiceVar);
        print(imagetoSend);
        //attendance stats
        present_status = true;
        String pre_stat_conv = present_status.toString();
        //  mark attendance
        //  inserting dummy data so that it dont give error after completion remove dymmy data
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          String? Checkin_gettingSharePrefs=prefs.getString("checkinaction");
        String currentMonthDay =  timeScreenState.CurrentMonth_DAY;

        bool isUserPresent = await isUserPresentForDate(getUser, formattedDate);
        if(isUserPresent){
          Fluttertoast.showToast(
            msg: "User has already punched in for today",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER,
            toastLength:Toast.LENGTH_SHORT,
          );
        }
        else{
          insertRegistered(
              getUser, getId, imagetoSend, pre_stat_conv, date.toString() ,"$currentMonthDay","$Checkin_gettingSharePrefs");

          // final player = AudioPlayer();
          // await player..setSource(AssetSource('assets/bell.mp3'));


          final player=AudioPlayer();
          player.play(AssetSource('bell.mp3'));


          //show toast
          // Fluttertoast.showToast(
          //   msg: " Sucess ",
          //   backgroundColor: Colors.green,
          //   gravity: ToastGravity.CENTER,
          //   toastLength:Toast.LENGTH_SHORT,
          // );


          var hourconv = timeScreenState.current_hour.toString();
          var minconv = timeScreenState.current_minuites.toString();


          // SucessScreen
          delayTimerForPageNavigation(0, context, SucessScreen());
          // _faceDetectorService.initialize();
          //

          Fluttertoast.showToast(
            msg: " user: $getUser --- Id: $getId --- time : $hourconv : $minconv ",
            backgroundColor: Colors.green,
            gravity: ToastGravity.CENTER,
            toastLength:Toast.LENGTH_SHORT,
          );
        }



        }
        else{
          Fluttertoast.showToast(
            msg: " user not detected ",
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
    else {

      // _faceDetectorService.initialize();
      setState(() {
        insertRegistered(
            "user not detected", "user not detected", "user not detected", "user not detected", date.toString() ,"user not detected","user not detected");
        image=null;
        User user = new User(user:"", password: "", modelData:List.empty());
        user.user="";
        user.password="";
        locked=false;
        present_status = false;

        _isPictureTaken= false;
        return;
      });
      print("present in else");
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


  Future<bool> isUserPresentForDate(String user, String time) async {
    final db = await SignInState.database;
    var res = await db!.rawQuery("SELECT * FROM userattendance WHERE username = ? AND attendancetime = ?", [user, time]);
    return res.isNotEmpty;
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
    attendancetime TEXT,
    day TEXT,
    attendancetype TEXT
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
  // day TEXT,
      // attendanceType TEXT,
  Future<void> insertRegistered(String username , String userId,String image , String presentstat , String attendancetime  , String day , String attendanceType)
  async{
    final db= await database;

    await db!.insert('userattendance', {

      'username':username,
      'userId':userId,
      'image':image,
      'presentstat':presentstat,
      'attendancetime':attendancetime,
      'day':day,
      'attendancetype':attendanceType,
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
      await cameraService.takePicture();
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
      return SinglePicture(imagePath: cameraService.imagePath!);
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
