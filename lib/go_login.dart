import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:vip_flutter/routes/logged_acc.dart';
import 'package:vip_flutter/routes/logged_accVIP.dart';

class GoLogin extends StatefulWidget {
  final String username;
  final String password;

  GoLogin({this.username, this.password});

  @override
  _GoLoginState createState() => _GoLoginState(username, password);
}

class _GoLoginState extends State<GoLogin> {
  String username;
  String password;

  _GoLoginState(this.username, this.password);

  String udid;
  String token;
  final String urlBase = "https://vip-serv.herokuapp.com/api";

  Future<dynamic> connect() async {
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

  Future<dynamic> getHelpers() async {
    Map<String, String> body = {
      "token": token,
      "UUID": udid,
    };
    var url = urlBase + "/get_helpers";
    var response = await http.post(url, body: body);
    return jsonDecode(response.body);
  }

  Future<dynamic> getVips() async {
    Map<String, String> body = {
      "token": token,
      "UUID": udid,
    };
    var url = urlBase + "/get_VIP";
    var response = await http.post(url, body: body);
    return jsonDecode(response.body);
  }

  Future<Null> _firebaseHelper() async {
    final DocumentReference postRef = Firestore.instance
        .collection("Users")
        .document('OnlineCount');
    Firestore.instance
        .runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot =
      await tx.get(postRef);
      if (postSnapshot.exists) {
        await tx.update(postRef, <String, dynamic>{
          'TotalOnline':
          postSnapshot.data['TotalOnline'] + 1
        });
        await tx.update(postRef, <String, dynamic>{
          'HelpersOnline':
          postSnapshot.data['HelpersOnline'] + 1
        });
      }
      Map<String, dynamic> body = {
        "$username": {
          "away": false,
          "online": true,
        }
      };
      Firestore.instance
          .collection('Users')
          .document('allUsers')
          .updateData(body);
      Firestore.instance
          .collection('Users')
          .document('allHelpers')
          .updateData(body);
    });
  }

  Future<Null> _firebaseVip () async {
    final DocumentReference postRef = Firestore.instance
        .collection("Users")
        .document('OnlineCount');
    Firestore.instance
        .runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot =
      await tx.get(postRef);
      if (postSnapshot.exists) {
        await tx.update(postRef, <String, dynamic>{
          'TotalOnline':
          postSnapshot.data['TotalOnline'] + 1
        });
        await tx.update(postRef, <String, dynamic>{
          'VipOnline': postSnapshot.data['VipOnline'] + 1
        });
      }
      Map<String, dynamic> body = {
        "$username": {
          "away": false,
          "online": true,
        }
      };
      Firestore.instance
          .collection('Users')
          .document('allUsers')
          .updateData(body);
      Firestore.instance
          .collection('Users')
          .document('allVip')
          .updateData(body); //Change to allVips
    });
  }

  Future<Null> _getUserInfo() async {
    debugPrint('Getting user info');

    Map response = await connect();
    bool isSuccess = response['success'];
    if (!isSuccess) {
      Fluttertoast.showToast(
          msg: '${response['error']}', toastLength: Toast.LENGTH_SHORT);
      Navigator.of(context).pop();
    } else {
      debugPrint(response['isHelper'] ? 'Getting vips...' : 'Getting helpers...');
      token = response['token'];

      Map<String, dynamic> resp;
      bool isHelper = response['isHelper'];
      if(isHelper)
        resp = await getVips();
      else
        resp = await getHelpers();

      if (!resp['success']) {
        Fluttertoast.showToast(
            msg: '${resp['error']}', toastLength: Toast.LENGTH_SHORT);
        Navigator.of(context).pop();
      } else {
        debugPrint('About to show data...');
        List<dynamic> users = jsonDecode(resp['users']);
        if(response['isHelper']) {
          await _firebaseHelper();
          setState(() {
            main = loggedAcc(token);
          });
        } else {
          await _firebaseVip();
          setState(() {
            main = loggedAccVIP(token, users, username);
          });
        }
      }
    }
  }

  Widget main = Center(child: CircularProgressIndicator());

  @override void initState() {
    super.initState();
    _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: main,
    );
  }
}
