import 'dart:convert';
import 'dart:io';

import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:face_net_authentication/pages/profile.dart';
import 'package:face_net_authentication/pages/sign-in.dart';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:face_net_authentication/pages/widgets/app_text_field.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../home.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;
class SignInSheet extends StatelessWidget {
  Future<Database>? _database;



  SignInSheet({Key? key, required this.user}) : super(key: key);
  final User user;//user from database

  final _passwordController = TextEditingController();
  final _cameraService = locator<CameraService>();
  bool present_status = false;
  var date = DateTime.now();

  Future _signIn(context, user) async {
    //here we can save database records
    if (user.password == _passwordController.text) {
      Navigator.push(
          context,
          MaterialPageRoute(

              builder: (BuildContext context) =>
                  // Profile(
                  //   user.user,
                  //   imagePath: _cameraService.imagePath!,
                  // )
                  SignIn()
          ));
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Text(
              'Welcome back, ' + user.user + '.',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            child: Column(
              children: [
                SizedBox(height: 10),
                AppTextField(
                  controller: _passwordController,
                  labelText: "ID",
                  keyboardType: TextInputType.number,
                  isPassword: true,
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                AppButton(
                  //here we will insert attendance record  and attendance will be marked
                  text: 'MARK ATTENDANCE',
                  onPressed: () async {
                    // _signIn(context, user);

                    _database=initializeDatabase();

                    String convtPass=_passwordController.text.toString();
                    String imgForDatabase = _cameraService.imagePath!;
                    String base64ImageVar=base64Image(imgForDatabase);
                    present_status=true;
                    String pre_stat_conv=present_status.toString();
                    insertRegistered(user.user,convtPass,base64ImageVar,pre_stat_conv,date.toString());

                    Fluttertoast.showToast(
                        msg:"attendance marked ",
                        backgroundColor: Colors.green,
                        gravity: ToastGravity.CENTER);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );

                  },
                  icon: Icon(
                    Icons.login,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


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


}
