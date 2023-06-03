import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class RegisteredUsers extends StatefulWidget {
  const RegisteredUsers({Key? key}) : super(key: key);

  @override
  State<RegisteredUsers> createState() => _RegisteredUsersState();
}

class _RegisteredUsersState extends State<RegisteredUsers> {

  Future<Database>? _database;
  Future<List<Map<String, dynamic>>> getRegistered() async {
    final db = await _database;
    return await db!.query('registered');
  }
  void initState() {
    super.initState();


  }


  Future<List<Map<String, dynamic>>> getData() async {
    // Get a location using getDatabasesPath
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'attendancedatabase.db');

    // Open the database
    final db = await openDatabase(path);

    // Query the database for all rows in a table
    final List<Map<String, dynamic>> result = await db.query('userattendance');

    // Close the database
    await db.close();

    // Return the result
    return result;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: <Widget>[

            Text(""),


            ElevatedButton(onPressed: () async {

              final List<Map<String, dynamic>> registered= await getData();
              //f1_p3
              print("database data $registered");
//  f1_p4
              for (var row in registered) {
                //getting specific data from database
                print('Username: ${row['username']}, User ID: ${row['userId']} , Base 64 Image:${row['image']}  , present stats :${row['presentstat']} , attendance time:${row['attendancetime']} ');
              }

            }, child:Text("GET DATA"))


          ],
        ),
      ),
    );
  }


}
