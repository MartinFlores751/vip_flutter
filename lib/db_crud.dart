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
String cookie;
http.Client client;

// ----------------
// Ruby Server CRUD
// ----------------
Future<dynamic> authenticateUser(String username, String password) async {
  debugPrint("Authenticating user...");

  String unencodedString = username + ':' + password;
  List<int> unencodedAuth = utf8.encode(unencodedString);
  Map<String, String> headers = {
    'Accept': 'application/json',
    'Authorization': 'Basic ' + base64.encode(unencodedAuth)
  };

  Map<String, String> body = {
    'UUID': await udid,
  };

  String unencodedPath = "/api/authenticate_user";
  Uri target = Uri.http(serverURL, unencodedPath);
  http.Response response =
      await client.post(target, body: body, headers: headers);

  if (response.headers['set-cookie'] != null)
    cookie = response.headers['set-cookie'];

  Map<String, dynamic> responseList = jsonDecode(response.body);
  return responseList;
}

Future<dynamic> getHelpers() async {
  debugPrint("Getting helpers...");

  Map<String, String> headers = {
    'Accept': 'application/json',
    'Cookie': cookie
  };

  Map<String, String> body = {
    "UUID": await udid,
  };

  String unencodedPath = "/api/get_helpers";
  Uri target = Uri.http(serverURL, unencodedPath);
  http.Response response =
      await client.post(target, body: body, headers: headers);

  if (response.headers['set-cookie'] != null)
    cookie = response.headers['set-cookie'];

  Map<String, dynamic> responseList = jsonDecode(response.body);
  return responseList;
}

Future<dynamic> getVips() async {
  debugPrint("Getting VIPs...");

  Map<String, String> headers = {
    'Accept': 'application/json',
    'Cookie': cookie
  };

  Map<String, String> body = {
    "UUID": await udid,
  };
  String unencodedPath = "/api/get_VIP";
  Uri target = Uri.http(serverURL, unencodedPath);
  http.Response response =
      await client.post(target, body: body, headers: headers);

  if (response.headers['set-cookie'] != null)
    cookie = response.headers['set-cookie'];

  Map<String, dynamic> responseList = jsonDecode(response.body);
  return responseList;
}

Future<dynamic> setStatus(Status status) async {
  debugPrint("Setting current user's status...");

  Map<String, String> headers = {
    'Accept': 'application/json',
    'Cookie': cookie
  };

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

  Map<String, String> body = {"UUID": await udid, "status": statusValue};

  http.Response response =
      await client.post(target, body: body, headers: headers);

  if (response.headers['set-cookie'] != null)
    cookie = response.headers['set-cookie'];

  Map<String, dynamic> responseList = jsonDecode(response.body);
  return responseList;
}

Future<dynamic> getFavorites(bool isHelper) async {
  debugPrint("Getting users current favorites...");

  Map<String, String> headers = {
    'Accept': 'application/json',
    'Cookie': cookie
  };

  String unencodedPath = "/api/get_favorites";
  Uri target = Uri.http(serverURL, unencodedPath);
  Map<String, String> body = {
    "UUID": await udid,
    "isHelper": isHelper.toString()
  };

  http.Response response =
      await client.post(target, body: body, headers: headers);

  if (response.headers['set-cookie'] != null)
    cookie = response.headers['set-cookie'];

  Map<String, dynamic> responseList = jsonDecode(response.body);
  return responseList;
}

Future<dynamic> addFavorite(String username) async {
  debugPrint("Adding $username to favorites...");

  Map<String, String> headers = {
    'Accept': 'application/json',
    'Cookie': cookie
  };

  String unencodedPath = "/api/add_favorites";
  Uri target = Uri.http(serverURL, unencodedPath);
  Map<String, String> body = {'UUID': await udid, 'username': username};

  // For some reason, client.post is not working here...
  http.Response response =
      await http.post(target, body: body, headers: headers);

  if (response.headers['set-cookie'] != null)
    cookie = response.headers['set-cookie'];

  Map<String, dynamic> responseList = jsonDecode(response.body);
  return responseList;
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
  client = http.Client();
  Map<String, dynamic> results = {
    'isSuccess': false,
    'error': '',
    'user': User(),
  };

  Map<dynamic, dynamic> response = await authenticateUser(username, password);
  bool isSuccess = response['success'];
  if (!isSuccess) {
    results['error'] = response['error'];
    return results;
  } else {
    Map<String, dynamic> resp;
    bool isHelper = response['isHelper'];
    if (isHelper)
      resp = await getVips();
    else
      resp = await getHelpers();

    if (!resp['success']) {
      results['error'] = resp['error'];
      return results;
    } else {
      debugPrint('About to show user home...');
      results['isSuccess'] = true;
      if (response['isHelper']) {
        _firebaseHelper(username);
        await setStatus(Status.online);
        results['user'].isHelper = true;
        return results;
      } else {
        _firebaseVip(username);
        await setStatus(Status.online);
        results['user'].isHelper = false;
        return results;
      }
    }
  }
}
