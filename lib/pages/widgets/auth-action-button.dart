import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/db/databse_helper.dart';
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:face_net_authentication/pages/profile.dart';
import 'package:face_net_authentication/pages/sign-in.dart';
import 'package:face_net_authentication/pages/sign-up.dart';
import 'package:face_net_authentication/pages/time_screen.dart';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:face_net_authentication/services/ml_service.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:sqflite/sqflite.dart';
import '../home.dart';
import 'app_text_field.dart';
//signup
class AuthActionButton extends StatefulWidget {
  AuthActionButton(
      {Key? key,
        required this.onPressed,
        required this.isLogin,
        required this.reload});
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {

  final MLService _mlService = locator<MLService>();
  final CameraService _cameraService = locator<CameraService>();

  final TextEditingController _userTextEditingController =
  TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController =
  TextEditingController(text: '');

  User? predictedUser;

  Future _signUp(context) async {
    DatabaseHelper _databaseHelper = DatabaseHelper.instance;
    List predictedData = _mlService.predictedData;
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;
    User userToSave = User(
      user: user,
      password: password,
      modelData: predictedData,
    );
    await _databaseHelper.insert(userToSave);
    this._mlService.setPredictedData([]);
    //adding anoher database
    // dynamic cvd =convertIntoBase64(predictedData).toString();
    // insertRegistered(user, password , cvd);

   var a= SignUpState.pathCapture;
   var b= base64Image(a!);
    SignUpState.insertRegistered(user,password,b);


    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => timeScreen()));
  }

  Future _signIn(context) async {
    String password = _passwordTextEditingController.text;
    if (this.predictedUser!.password == password) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Profile(
                this.predictedUser!.user,
                imagePath: _cameraService.imagePath!,
              )));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Wrong password!'),
          );
        },
      );
    }
  }

  Future<User?> _predictUser() async {
    User? userAndPass = await _mlService.predict();
    return userAndPass;
  }

  Future onTap() async {
    try {
      bool faceDetected = await widget.onPressed();
      if (faceDetected) {
        if (widget.isLogin) {
          var user = await _predictUser();
          if (user != null) {
            this.predictedUser = user;
          }
        }
        PersistentBottomSheetController bottomSheetController =
        Scaffold.of(context)
            .showBottomSheet((context) => signSheet(context));
        bottomSheetController.closed.whenComplete(() => widget.reload());
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[200],
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CAPTURE',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.white)
          ],
        ),
      ),
    );
  }

  signSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? Container(
            child: Text(
              'Welcome back, ' + predictedUser!.user + '.',
              style: TextStyle(fontSize: 20),
            ),
          )
              : widget.isLogin
              ? Container(
              child: Text(
                'User not found 😞',
                style: TextStyle(fontSize: 20),
              ))
              : Container(),
          Container(
            child: Column(
              children: [
                !widget.isLogin
                    ? AppTextField(
                  controller: _userTextEditingController,
                  labelText: "Your Name",
                )
                    : Container(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser == null
                    ? Container()
                    : AppTextField(
                  keyboardType: TextInputType.number,
                  controller: _passwordTextEditingController,
                  labelText: "ID",
                  isPassword: true,
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser != null
                    ? AppButton(
                  text: 'LOGIN',
                  onPressed: () async {
                    _signIn(context);
                  },
                  icon: Icon(
                    Icons.login,
                    color: Colors.white,
                  ),
                )
                    : !widget.isLogin
                    ? AppButton(
                  text: 'SIGN UP',
                  onPressed: () async {
                    await _signUp(context);
                  },
                  icon: Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

void initState(){
    super.initState();

}

  String base64Image(String imagePath) {
    File imageFile = File(imagePath);
    List<int> imageBytes = imageFile.readAsBytesSync();
    return base64Encode(imageBytes);
  }
// List To Base 64 conversion
//   String convertIntoBase64(List<dynamic> imageBytes) {
//     String base64File = base64Encode(imageBytes.cast<int>() );
//     return base64File;
//   }

  // String base64Image(XFile file) {
  //   List<int> imageBytes = file.readAsBytesSync();
  //   return base64Encode(imageBytes);
  // }




  // String convertIntoBase64(List<dynamic> imageBytes) {
  //   Uint8List bytes = Uint8List.fromList(imageBytes.cast<int>());
  //   String base64File = base64Encode(bytes);
  //
  //   return base64File;
  // }
}