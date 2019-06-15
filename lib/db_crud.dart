import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_udid/flutter_udid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:vip_flutter/user_class.dart';

enum Status { offline, away, online }

//
// vip-serv.herokuapp.com
// const String serverURL = '192.168.1.127:4567';
const String serverURL = 'vip-serv.herokuapp.com';
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

  String unencodedPath = "/api/authenticate_user";
  Uri target = Uri.http(serverURL, unencodedPath);
  http.Response response = await http.post(target, body: body);
  return jsonDecode(response.body);
}

Future<dynamic> getHelpers(String token) async {
  Map<String, String> body = {
    "token": token,
    "UUID": await udid,
  };

  String unencodedPath = "/api/get_helpers";
  Uri target = Uri.http(serverURL, unencodedPath);
  http.Response response = await http.post(target, body: body);
  return jsonDecode(response.body);
}

Future<dynamic> getVips(String token) async {
  Map<String, String> body = {
    "token": token,
    "UUID": await udid,
  };
  String unencodedPath = "/api/get_VIP";
  Uri target = Uri.http(serverURL, unencodedPath);
  http.Response response = await http.post(target, body: body);
  return jsonDecode(response.body);
}

Future<dynamic> setStatus(String token, Status status) async {
  String unencodedPath = "/api/set_status";
  Uri target = Uri.http(serverURL, unencodedPath);
  String statusValue;

  switch (status) {
    case Status.online:
      statusValue = '2';
      break;
    case Status.away:
      statusValue = '1';
      break;
    case Status.offline:
      statusValue = '0';
      break;
  }

  Map<String, String> body = {
    "token": token,
    "UUID": await udid,
    "status": statusValue
  };

  http.Response response = await http.post(target, body: body);
  return jsonDecode(response.body);
}

Future<dynamic> getFavorites(String token, bool isHelper) async {
  String unencodedPath = "";
  Uri target = Uri.http(serverURL, unencodedPath);
  Map<String, String> body = {
    "token": token,
    "UUID": await udid,
    "isHelper": isHelper.toString()
  };

  http.Response response = await http.post(target, body: body);
  return jsonDecode(response.body);
}

Future<dynamic> addFavorite(String token, String username) async {
  String unencodedPath = "";
  Uri target = Uri.http(serverURL, unencodedPath);
  Map<String, String> body = {
    'token': token,
    'UUID': await udid,
    'username': username
  };

  http.Response response = await http.post(target, body: body);
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
      if (response['isHelper']) {
        _firebaseHelper(username);
        setStatus(token, Status.online);
        results['user'].isHelper = true;
        return results;
      } else {
        _firebaseVip(username);
        setStatus(token, Status.online);
        results['user'].isHelper = false;
        return results;
      }
    }
  }
}
