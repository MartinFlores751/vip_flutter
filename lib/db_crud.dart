import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_udid/flutter_udid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:vip_flutter/user_class.dart';


const String serverURL = 'https://vip-serv.herokuapp.com/api';
Future<String> udid = FlutterUdid.consistentUdid;

// ----------------
// Ruby Server CRUD
// ----------------
Future<dynamic> authenticateUser(String username, String password) async {
  Map<String, String> body = {
    'user': username,
    'password': password,
    'UUID': await udid,
  };

  String targetURL = serverURL + "/authenticate_user";
  var response = await http.post(targetURL, body: body);
  return jsonDecode(response.body);
}

Future<dynamic> getHelpers(String token) async {
  Map<String, String> body = {
    "token": token,
    "UUID": await udid,
  };

  var targetURL = serverURL + "/get_helpers";
  var response = await http.post(targetURL, body: body);
  return jsonDecode(response.body);
}

Future<dynamic> getVips(String token) async {
  Map<String, String> body = {
    "token": token,
    "UUID": await udid,
  };
  var targetURL = serverURL + "/get_VIP";
  var response = await http.post(targetURL, body: body);
  return jsonDecode(response.body);
}

// -------------
// Firebase CRUD
// -------------

// No Idea what this does...
Future<Null> _firebaseHelper(String username) async {
  final DocumentReference postRef =
      Firestore.instance.collection("Users").document('OnlineCount');
  Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(postRef);
    if (postSnapshot.exists) {
      await tx.update(postRef, <String, dynamic>{
        'TotalOnline': postSnapshot.data['TotalOnline'] + 1
      });
      await tx.update(postRef, <String, dynamic>{
        'HelpersOnline': postSnapshot.data['HelpersOnline'] + 1
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

Future<Null> _firebaseVip(String username) async {
  final DocumentReference postRef =
      Firestore.instance.collection("Users").document('OnlineCount');
  Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(postRef);
    if (postSnapshot.exists) {
      await tx.update(postRef, <String, dynamic>{
        'TotalOnline': postSnapshot.data['TotalOnline'] + 1
      });
      await tx.update(postRef,
          <String, dynamic>{'VipOnline': postSnapshot.data['VipOnline'] + 1});
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

Future<Map<String, dynamic>> doAuthCRUD(
    String username, String password) async {
  Map<String, dynamic> results = {
    'isSuccess': false,
    'error': '',
    'user': User(),
  };

  debugPrint('Getting user info');

  Map<dynamic, dynamic> response = await authenticateUser(username, password);
  bool isSuccess = response['success'];
  if (!isSuccess) {
    results['error'] = response['error'];
    return results;
  } else {
    debugPrint(response['isHelper'] ? 'Getting vips...' : 'Getting helpers...');
    String token = response['token'];

    Map<String, dynamic> resp;
    bool isHelper = response['isHelper'];
    if (isHelper)
      resp = await getVips(token);
    else
      resp = await getHelpers(token);

    if (!resp['success']) {
      results['error'] = resp['error'];
      return results;
    } else {
      debugPrint('About to show data...');
      results['isSuccess'] = true;
      results['user'].token = token;
      // List<dynamic> users = jsonDecode(resp['users']);
      if (response['isHelper']) {
        await _firebaseHelper(username);
        results['user'].isHelper = true;
        return results;
      } else {
        await _firebaseVip(username);
        results['user'].isHelper = false;
        return results;
      }
    }
  }
}
