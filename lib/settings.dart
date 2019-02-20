import 'package:flutter/material.dart';

class AccSettings extends StatefulWidget {
  _AccSettingsState createState() => _AccSettingsState();
}

class _AccSettingsState extends State<AccSettings> {
  @override
  Widget build(BuildContext context) {
    //WIP: change IconButton to FlatButton with an image as the child
    var accIcon = IconButton(
      icon: Icon(Icons.account_box),
      color: Colors.white,
      iconSize: 80,
      onPressed: () {
        //Change Profile Picture
      }
    );

    return Scaffold(
      appBar: AppBar(title: Text('')),
      //WIP: Add factors that users would like to customize
      //
      //Tentative: Profile Picture, Set up Nickname (to hide private info), Consent to being recorded, 
      //           Update personal information,  update email
      body: ListView(
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
              title: Text('Update Information'),
              onTap: () {
                //WIP: Create page to update info of profile class
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => UpdatePage()),
                // );
              },
            ),
            ListTile(
              title: Text('Setup Nickname'),
              onTap: () {
                //WIP: Optional to have an extra layer of privacy
                //     Once set, the user's name should be set as nickname
              },
            ),
            ListTile(
              title: Text('Update Email'),
              onTap: () {
                //WIP: Simple popup to edit email
              },
            ),
            SwitchListTile(
              title: Text('Allow Observation of Communications?'),
              subtitle: Text('Please review our policy on Observations'),
              //should be false by default! Respect their privacy
              value: false,
              onChanged: (bool newValue) {
                //WIP: Show a pop up screen with Consent document and what we do with their information
              },
            ),
            SwitchListTile(
              title: Text('Use nickname?'),
              value: true,
              onChanged: (bool newValue) {
                //WIP: Show a pop up screen with Consent document and what we do with their information
              },
            ),
          ],
        ),
    );
  }
}