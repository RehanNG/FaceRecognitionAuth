//getting all users from database
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'db/databse_helper.dart';
import 'sign-up.dart';
class GettingAllUsersFromDataBase extends StatefulWidget {
  const GettingAllUsersFromDataBase({Key? key}) : super(key: key);

  @override
  State<GettingAllUsersFromDataBase> createState() => _GettingAllUsersFromDataBaseState();
}

class _GettingAllUsersFromDataBaseState extends State<GettingAllUsersFromDataBase> {
   var myUser;
   var allUsers ;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:ListView(
        children: <Widget>[


          TextButton(onPressed: ()async{

            List<User> users = await DatabaseHelper.queryAllUsers();
            for (User u in users) {
              print(u.user);
              print(u.password);
            }


          }, child: Text("get users"))


        ],
      ),
    );
  }



//   Future<List<Map<String, dynamic>>> fetchDataFromDatabase() async {
//     // Open the database
//     final Database db = await openDatabase('my_database.db');
//
//     // Query the database for all rows in the 'users' table
//     final List<Map<String, dynamic>> users = await db.rawQuery('SELECT * FROM registered');
//
//     // Close the database
//     await db.close();
// myUser=users;
//     // Return the list of users
//     return myUser;
//   }



   _query() async {
     final Database db = await openDatabase("MyDatabase.db");
     // get a reference to the database

     // get all rows
     List<Map> result = await db.query(DatabaseHelper.table);

     // print the results
     result.forEach((row) => print(row));
     // {_id: 1, name: Bob, age: 23}
     // {_id: 2, name: Mary, age: 32}
     // {_id: 3, name: Susan, age: 12}
   }



}
