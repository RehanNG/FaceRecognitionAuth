import 'package:flutter/material.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';
import '../pages/db/databse_helper.dart';
import '../pages/models/user.model.dart';




getUserInfo()async{
  List<User> users = await DatabaseHelper.queryAllUsers();
  for (User u in users) {
    var getUsers = u.user;
    var getIDs = u.password;
    print(u.user);
    print(u.password);

    Text(" user  $getUsers : Id $getIDs");


    SizedBox(

      width: 500,
      height: 300,

      child:ScrollableTableView(
        columns:[
          "user_id",
          "user_name",
        ].map((column) {
          return TableViewColumn(
            label: column,
          );
        }).toList(),
        rows: [
          ["$getIDs", "$getUsers"],
          // ["PR1001", "Soap"],
        ].map((record) {
          return TableViewRow(
            height: 60,
            cells: record.map((value) {
              return TableViewCell(
                child: Text(value),
              );
            }).toList(),
          );
        }).toList(),
      ),



    );





  }
}
