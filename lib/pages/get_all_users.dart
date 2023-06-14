//getting all users from database
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'db/databse_helper.dart';
class GettingAllUsersFromDataBase extends StatefulWidget {
  const GettingAllUsersFromDataBase({Key? key}) : super(key: key);

  @override
  State<GettingAllUsersFromDataBase> createState() => _GettingAllUsersFromDataBaseState();
}

class _GettingAllUsersFromDataBaseState extends State<GettingAllUsersFromDataBase> {

   @override
   void initState() {
     super.initState();
     _loadUsers();
   }

   List<User> _users = [];
   Future<void> _loadUsers() async {
     List<User> users = await DatabaseHelper.queryAllUsers();
     setState(() {
       _users = users;
     });
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users List"),
        backgroundColor: Colors.indigo,
      ),
      body:ListView.builder(
        itemCount: _users.length,
        itemBuilder: (BuildContext context , int index){
          User user = _users[index];

          return Padding(
            padding: const EdgeInsets.all(17),
            child: CustomCard(
              height: 60,
             borderRadius: 10,
             color: Colors.indigoAccent,
             hoverColor: Colors.indigo,


             onTap: (){},
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text('User: ${user.user}',style: TextStyle(color: Colors.white),),
                 Text('ID: ${user.password}',style: TextStyle(color: Colors.white)),
               ],
             ),
            ),
          );

        }


      ),
    );
  }









}
