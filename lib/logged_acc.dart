import 'package:flutter/material.dart';

class loggedAcc extends StatefulWidget {
  _loggedAccState createState() => _loggedAccState();
}

class _loggedAccState extends State<loggedAcc> {
  @override
  Widget build(BuildContext context) {
    var accIcon = IconButton(
      icon: Icon(Icons.account_box),
      color: Colors.white,
      iconSize: 80,
      onPressed: () {
        //show account information?
      }
    );

    return Scaffold(
      appBar: AppBar(title: Text('')),
      //add a body
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          children: <Widget>[
            DrawerHeader(
              child: Row(
                children: [accIcon,
                  Text('Account Name', style: new TextStyle(fontSize: 20, color: Colors.white),),
                ],
              ),
              decoration: BoxDecoration( 
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}