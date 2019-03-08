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
import 'package:flutter_udid/flutter_udid.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _username = TextEditingController();
  var _password = TextEditingController();
  String token; //will hold Token that is retrieved from the server

  Future<dynamic> connect() async{
    String udid = await FlutterUdid.consistentUdid;
    Map<String, String> body = {
      'user': _username.text,
      'password': _password.text,
      'UUID': udid,
    };
    var url = "https://vip-serv.herokuapp.com/api/authenticate_user";
    var response = await http.post(url, body: body);
    return response;
  }

  void login() async{
    if (_username.text.length == 0 || _password.text.length == 0)
    {
      Fluttertoast.showToast(msg: 'Field(s) Empty',toastLength: Toast.LENGTH_SHORT);
      return;
    }
    var response = await connect();
    if (response.body != "Account does not Exist" && response.body != "Incorrect Password"){
      token = response.body;
      Fluttertoast.showToast(msg: 'Login Successful',toastLength: Toast.LENGTH_SHORT);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => loggedAcc(token)),
      );
    }
    else{
      Fluttertoast.showToast(msg: '${response.body}',toastLength: Toast.LENGTH_SHORT);
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