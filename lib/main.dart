/*
 * Copyright (C) 2019. The AUTHORS - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'sign_up.dart';
import 'logged_acc.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _username = TextEditingController();
  var _password = TextEditingController();

  Future<dynamic> connect() async{
    if (_username.text.length == 0 || _password.text.length == 0)
    {
      return null;
    }
    Map<String, String> body = {
      'user': _username.text,
      'password': _password.text,
    };
    var url = "https://vip-serv.herokuapp.com/api/authenticate_user";
    var response = await http.post(url, body: body);
    return response;
  }

  void login() async{
    var response = await connect();
    if (response == null)
    {
      Fluttertoast.showToast(msg: 'Field(s) Empty',toastLength: Toast.LENGTH_SHORT);
      return;
    }
    Fluttertoast.showToast(msg: '${response.body}',toastLength: Toast.LENGTH_SHORT);
    if (response.body == "Log in Successful")
    {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => loggedAcc()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var loginCredentials = new Column(children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          width: 160,
          height: 50,
          child: TextFormField(
            inputFormatters: [
              new WhitelistingTextInputFormatter(new RegExp("[a-zA-Z0-9]")),
            ],
            controller: _username,
            autofocus: false,
            obscureText: false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
              //border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelText: 'Username'
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          width: 160,
          height: 50,
          child: TextFormField(
            inputFormatters: [
              new BlacklistingTextInputFormatter(new RegExp("[ ]")),
            ],
            controller: _password,
            autofocus: false,
            obscureText: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
              //border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelText: 'Password'
            ),
          ),
        ),
      ],
    );

    var loggedAccScreen = IconButton(
      icon: Icon(Icons.arrow_forward),
      color: Colors.blue,
      iconSize: 55,
      onPressed: () {
        //check to see if credentials exist
        login();
      }
    );

    var createNewUser = new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('New User?'),
        FlatButton(
          child: Text(
            'Sign Up',
            style: TextStyle(color: Colors.blue),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => signUp()),
            );
          },
        )
      ]
    );


    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: new Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[loginCredentials, loggedAccScreen, createNewUser],
          ),
        ),
      ),
    );
  }
}