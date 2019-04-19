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
import 'dart:io';
import 'sign_up.dart';
import 'logged_acc.dart';
import 'logged_accVIP.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class GoLogin extends StatefulWidget {
  String username;
  String password;
  GoLogin(this.username, this.password);
  @override
  _GoLoginState createState() => _GoLoginState(username, password);
}

class _GoLoginState extends State<GoLogin> {
  String username;
  String password;
  _GoLoginState(this.username, this.password);
  String udid;
  String token;
  String urlBase = "https://vip-serv.herokuapp.com/api";

  Future<dynamic> connect() async{
    udid = await FlutterUdid.consistentUdid;
    Map<String, String> body = {
      'user': username,
      'password': password,
      'UUID': udid,
    };
    var url = urlBase + "/authenticate_user";
    var response = await http.post(url, body: body);
    return jsonDecode(response.body);
  }
  Future<dynamic> getHelpers() async{
    Map<String, String> body = {
      "token": token,
      "UUID": udid,
    };
    var url = urlBase + "/get_helpers";
    var response = await http.post(url, body: body);
    return jsonDecode(response.body);
  }
  Future<dynamic> getVips() async{
    Map<String, String> body = {
      "token": token,
      "UUID": udid,
    };
    var url = urlBase + "/get_VIP";
    var response = await http.post(url, body: body);
    return jsonDecode(response.body);
  }
  @override
  Widget build(BuildContext context) {
    var a = FutureBuilder<dynamic>(
      future: connect(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return CircularProgressIndicator();
          case ConnectionState.active:
            return CircularProgressIndicator();
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          case ConnectionState.done:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            var response = snapshot.data;
            print("PASS CONNECT: $response");
            if (response["success"]){
              bool helper = response["isHelper"];
              token = response["token"];
              print("GOING IN BOIS");
              return FutureBuilder<dynamic>(
                  future: helper ? getVips() : getHelpers(), // a previously-obtained Future<String> or null
                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return CircularProgressIndicator();
                      case ConnectionState.active:
                        return CircularProgressIndicator();
                      case ConnectionState.waiting:
                        return CircularProgressIndicator();
                      case ConnectionState.done:
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');
                        var response2 = snapshot.data;
                        if (response2["success"]){
                          List<dynamic> allusers = jsonDecode(response2["users"]);
                          Fluttertoast.showToast(msg: 'Login Successful',toastLength: Toast.LENGTH_SHORT);
                          if (helper == false){
                            final DocumentReference postRef = Firestore.instance.collection("Users").document('OnlineCount');
                            Firestore.instance.runTransaction((Transaction tx) async {
                              DocumentSnapshot postSnapshot = await tx.get(postRef);
                              if (postSnapshot.exists) {
                                await tx.update(postRef, <String, dynamic>{'TotalOnline': postSnapshot.data['TotalOnline'] + 1});
                                await tx.update(postRef, <String, dynamic>{'VipOnline': postSnapshot.data['VipOnline'] + 1});
                              }
                              Map<String, dynamic> body = {
                                  "${username}":{
                                  "away": false,
                                  "online": true,
                                }
                              };
                              Firestore.instance.collection('Users').document('allUsers').updateData(body);
                              Firestore.instance.collection('Users').document('allVip').updateData(body); //Change to allVips
                            });
                            return loggedAccVIP(token, allusers, username);
                          }
                          else
                          {
                            final DocumentReference postRef = Firestore.instance.collection("Users").document('OnlineCount');
                            Firestore.instance.runTransaction((Transaction tx) async {
                              DocumentSnapshot postSnapshot = await tx.get(postRef);
                              if (postSnapshot.exists) {
                                await tx.update(postRef, <String, dynamic>{'TotalOnline': postSnapshot.data['TotalOnline'] + 1});
                                await tx.update(postRef, <String, dynamic>{'HelpersOnline': postSnapshot.data['HelpersOnline'] + 1});
                              }
                              Map<String, dynamic> body = {
                                "${username}":{
                                  "away": false,
                                  "online": true,
                                }
                              };
                              Firestore.instance.collection('Users').document('allUsers').updateData(body);
                              Firestore.instance.collection('Users').document('allHelpers').updateData(body);
                            });
                            return loggedAcc(token); //replace (token) with (token, allusers, _username.text)
                          }
                        }
                    }
                    return null; // unreachable
                  },
                );
            }
            else{
              Fluttertoast.showToast(msg: '${response["error"]}',toastLength: Toast.LENGTH_SHORT);
            }
        }
        return null; // unreachable
      },
    );
    return Scaffold(
      //appBar: AppBar(title: Text("")),
      body: Align(
        alignment: FractionalOffset(.5, .5),
        child: a,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{
  var _username = TextEditingController();
  var _password = TextEditingController();
  String urlBase = "https://vip-serv.herokuapp.com/api";
  
  @override
  Widget build(BuildContext context) {
    FocusNode textSecondFocusNode = new FocusNode();

    var loginCredentials = new Column(children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          width: MediaQuery.of(context).size.width/1.5,
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
            decoration: new InputDecoration(
              border: new OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  borderSide: new BorderSide(color: Colors.teal)),
              hintText: 'Username',
              labelText: 'Username',
              prefixIcon: const Icon(
                Icons.person,
                color: Colors.blue,
              ),
              prefixText: ' ',
            ),
          ),
        ),
        SizedBox(height: 10,),
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          width: MediaQuery.of(context).size.width/1.5,
          child: TextFormField(
            inputFormatters: [
              new BlacklistingTextInputFormatter(new RegExp("[ ]")),
            ],
            focusNode: textSecondFocusNode,
            controller: _password,
            autofocus: false,
            obscureText: true,
            decoration: new InputDecoration(
              border: new OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  borderSide: new BorderSide(color: Colors.teal)),
              hintText: '******',
              labelText: 'Password',
              prefixIcon: const Icon(
                Icons.enhanced_encryption,
                color: Colors.blue,
              ),
              suffixStyle: const TextStyle(color: Colors.green)
            ),
          ),
        ),
      ],
    );

    var loggedAccScreen2 = RaisedButton(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text("Login"),
      color: Colors.blue[200],
      onPressed: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  GoLogin(_username.text, _password.text)),
        );
      },
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
              MaterialPageRoute(builder: (context) => signUp(urlBase)),
            );
          },
        )
      ]
    );
    var theIcon = Icon(
      Icons.camera,
      size: 90,
      //color: Colors.blue[800],
    );
    var theContainer = Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(width: 5, color: Colors.black)
        
      ),
      child: theIcon,
    );

    return Scaffold(
      //resizeToAvoidBottomPadding: false,
      body: new Align(
        alignment: FractionalOffset(.5, .5),
        child: Container(
          //padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height/5, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[theContainer, SizedBox(height: 15), loginCredentials, loggedAccScreen2, createNewUser],
          ),
        ),
      ),
    );
  }
}