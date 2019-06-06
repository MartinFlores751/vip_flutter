import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

class AccSettings extends StatefulWidget {
  _AccSettingsState createState() => _AccSettingsState();
}

class _AccSettingsState extends State<AccSettings> {
  bool _doesConsent = false;
  bool _useNick = true;
  var _nick = TextEditingController();
  var _email = TextEditingController();
  var _confirmEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //WIP: change IconButton to FlatButton with an image as the child
    var accIcon = IconButton(
        icon: Icon(Icons.account_box),
        color: Colors.white,
        iconSize: 80,
        onPressed: () {
          //Change Profile Picture
        });

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
              children: [
                accIcon,
                Text(
                  'Account Name',
                  style: new TextStyle(fontSize: 20, color: Colors.white),
                ),
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
              SimpleDialog dialog = SimpleDialog(
                  title: Text("Complete the Form"),
                  children: [
                    TextFormField(
                      controller: _nick,
                      autofocus: false,
                      obscureText: false,
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                          //border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          labelText: 'Create Your Nickname'),
                    ),
                    IconButton(
                        icon: Icon(Icons.check),
                        color: Colors.blue,
                        iconSize: 25,
                        padding: EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 0.0),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop(true);
                          _nick.text = "";
                          Fluttertoast.showToast(
                              msg: 'Nickname set!',
                              toastLength: Toast.LENGTH_SHORT);
                        }),
                  ],
                  contentPadding:
                      const EdgeInsets.fromLTRB(25.0, 12.0, 25.0, 25.0));
              showDialog(
                  context: context, builder: (BuildContext context) => dialog);
            },
          ),
          ListTile(
            title: Text('Update Email'),
            onTap: () {
              //WIP: Simple popup to edit email
              SimpleDialog dialog = SimpleDialog(
                  title: Text("Complete the Form"),
                  children: [
                    TextFormField(
                      controller: _email,
                      autofocus: false,
                      obscureText: false,
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                          labelText: 'New Email'),
                    ),
                    TextFormField(
                      controller: _confirmEmail,
                      autofocus: false,
                      obscureText: false,
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                          labelText: 'Confirm Email'),
                    ),
                    IconButton(
                        icon: Icon(Icons.check),
                        color: Colors.blue,
                        iconSize: 25,
                        padding: EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 0.0),
                        onPressed: () {
                          if (_email.text == _confirmEmail.text) {
                            _email.text = "";
                            _confirmEmail.text = "";
                            Navigator.of(context, rootNavigator: true)
                                .pop(true);
                          } else
                            Fluttertoast.showToast(
                                msg: "Emails don't Match!",
                                toastLength: Toast.LENGTH_SHORT);
                        }),
                  ],
                  contentPadding:
                      const EdgeInsets.fromLTRB(25.0, 12.0, 25.0, 25.0));
              showDialog(
                  context: context, builder: (BuildContext context) => dialog);
            },
          ),
          SwitchListTile(
            title: Text('Allow Observation of Communications?'),
            subtitle: Text('Please review our policy on Observations'),
            //should be false by default! Respect their privacy
            value: _doesConsent,
            onChanged: (bool newValue) {
              //WIP: Show a pop up screen with Consent document and what we do with their information
              setState(() {
                _doesConsent = newValue;
              });
              //TIP: pop up for consent form
              SimpleDialog dialog = SimpleDialog(
                  title: Text("Consent Form"),
                  children: [
                    Text("By hitting the switch 'on' you have consented to occasional" +
                        " surveillance so our services can continue to improve!")
                  ],
                  contentPadding:
                      const EdgeInsets.fromLTRB(25.0, 12.0, 25.0, 25.0));
              showDialog(
                  context: context, builder: (BuildContext context) => dialog);
            },
          ),
          SwitchListTile(
            title: Text('Use nickname?'),
            value: _useNick,
            onChanged: (bool newValue) {
              //WIP: Show a pop up screen with Consent document and what we do with their information
              setState(() {
                _useNick = newValue;
              });
            },
          ),
        ],
      ),
    );
  }
}
