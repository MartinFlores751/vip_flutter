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
import 'logged_accVIP.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
  String udid;
  String token;

  Future<dynamic> connect() async{
    udid = await FlutterUdid.consistentUdid;
    Map<String, String> body = {
      'user': _username.text,
      'password': _password.text,
      'UUID': udid,
    };
    var url = "https://vip-serv.herokuapp.com/api/authenticate_user";
    var response = await http.post(url, body: body);
    print("${response.body}");
    return jsonDecode(response.body);
  }
  Future<dynamic> getHelpers() async{
    print("IN");
    print("$token  $udid");
    var url = "https://vip-serv.herokuapp.com/api/get_helpers?token=$token&UUID=$udid";
    var response = await http.get(url);
    print("OUT");
    print("${response.body}");
    return jsonDecode(response.body);
  }

  void login() async{
    if (_username.text.length == 0 || _password.text.length == 0)
    {
      Fluttertoast.showToast(msg: 'Field(s) Empty',toastLength: Toast.LENGTH_SHORT);
      return;
    }
    var response = await connect();
    if (response["success"]){
      bool helper = response["isHelper"];
      token = response["token"];
      var vipresponse = await getHelpers();
      if (vipresponse["success"]){
        List<dynamic> allhelpers = vipresponse["users"];
        Fluttertoast.showToast(msg: 'Login Successful',toastLength: Toast.LENGTH_SHORT);
        if (helper == false){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => loggedAccVIP(token, allhelpers)),
          );
        }
        else
        {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => loggedAcc(token)), //replace (token) with (token, allvip)
          );
        }
      }
      else {
        token = "";
      }
    }
    else{
      Fluttertoast.showToast(msg: '${response["error"]}',toastLength: Toast.LENGTH_SHORT);
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusNode textSecondFocusNode = new FocusNode();

    var loginCredentials = new Column(children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          width: 160,
          height: 50,
          child: TextFormField(
            inputFormatters: [
              new WhitelistingTextInputFormatter(new RegExp("[a-zA-Z0-9]")),
            ],
            onFieldSubmitted: (String value) {
              FocusScope.of(context).requestFocus(textSecondFocusNode);
            },
            controller: _username,
            autofocus: false,
            obscureText: false,
            textInputAction: TextInputAction.next,
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
            focusNode: textSecondFocusNode,
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
      resizeToAvoidBottomPadding: false,
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