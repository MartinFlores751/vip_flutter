import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';

class SignUp extends StatefulWidget {
  final String urlBase;
  SignUp(this.urlBase);
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _fullName = TextEditingController();
  TextEditingController _userName = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _conPass = TextEditingController();

  FocusNode _fullNameNode = FocusNode();
  FocusNode _userNameNode = FocusNode();
  FocusNode _passwordNode = FocusNode();
  FocusNode _conPassNode = FocusNode();

  CircularBottomNavigationController _navControl =
      CircularBottomNavigationController(0);

  Future<dynamic> connect() async {
    String udid = await FlutterUdid.consistentUdid;
    if (!_formKey.currentState.validate()) {
      debugPrint('Bad boi');
      return null;
    }

    debugPrint(_navControl.value.toString());
    Map<String, String> body = {
      'name': _fullName.text,
      'user': _userName.text,
      'helper': _navControl.value.toString(),
      'password': _password.text,
      'c_password': _conPass.text,
      'UUID': udid,
    };
    String unendodedPath = "/api/register_user";
    Uri target = Uri.http(widget.urlBase, unendodedPath);
    var response = await http.post(target, body: body);
    return jsonDecode(response.body);
  }

  void signup() async {
    var response = await connect();
    if (response == null) {
      Fluttertoast.showToast(
          msg: 'Field(s) Empty', toastLength: Toast.LENGTH_SHORT);
      return;
    } else if (response["success"]) {
      Map<String, dynamic> body = {
        "${_userName.text}": {
          "away": false,
          "online": false,
        }
      };
      Firestore.instance
          .collection('Users')
          .document('allUsers')
          .updateData(body);
      if (_navControl.value == 1) {
        Firestore.instance
            .collection('Users')
            .document('allHelpers')
            .updateData(body);
      } else {
        Firestore.instance
            .collection('Users')
            .document('allVip')
            .updateData(body);
      }
      Fluttertoast.showToast(
          msg: 'Account Created!', toastLength: Toast.LENGTH_SHORT);
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
          msg: '${response["error"]}', toastLength: Toast.LENGTH_SHORT);
    }
  }

  Widget get _signUpChoice {
    return CircularBottomNavigation(
      <TabItem>[
        TabItem(Icons.accessibility_new, "VIP", Theme.of(context).accentColor),
        TabItem(Icons.visibility, "Helper", Theme.of(context).primaryColor),
      ],
      controller: _navControl,
      barHeight: 60.0,
      barBackgroundColor: Theme.of(context).canvasColor,
      animationDuration: Duration(milliseconds: 300),
    );
  }

  Widget get _nameField {
    return Container(
        width: MediaQuery.of(context).size.width * 0.75,
        margin: EdgeInsets.only(bottom: 10.0),
        child: TextFormField(
          inputFormatters: [
            WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
          ],
          controller: _fullName,
          focusNode: _fullNameNode,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide(color: Theme.of(context).accentColor)),
            hintText: 'Full Name',
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.face, color: Theme.of(context).primaryColor),
          ),
          validator: (value) {
            if (value.length == 0) return 'Please input your full name.';
          },
          onEditingComplete: () =>
              FocusScope.of(context).requestFocus(_userNameNode),
        ));
  }

  Widget get _userNameField {
    return Container(
        width: MediaQuery.of(context).size.width * 0.75,
        margin: EdgeInsets.only(bottom: 10.0),
        child: TextFormField(
          inputFormatters: [
            WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),
          ],
          controller: _userName,
          focusNode: _userNameNode,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide(color: Theme.of(context).accentColor)),
            labelText: 'Username',
            hintText: 'Username',
            prefixIcon:
                Icon(Icons.person, color: Theme.of(context).primaryColor),
          ),
          validator: (value) {
            if (value.length == 0) return 'Please input a username.';
          },
          onEditingComplete: () =>
              FocusScope.of(context).requestFocus(_passwordNode),
        ));
  }

  Widget get _passwordField {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
          inputFormatters: [
            WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9 ]")),
          ],
          controller: _password,
          focusNode: _passwordNode,
          textInputAction: TextInputAction.next,
          obscureText: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide(color: Theme.of(context).accentColor)),
            labelText: 'Password',
            hintText: 'Password',
            prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
          ),
          validator: (value) {
            if (value.length == 0) return 'Please input a password.';
          },
          onEditingComplete: () =>
              FocusScope.of(context).requestFocus(_conPassNode)),
    );
  }

  Widget get _conPassField {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
          inputFormatters: [
            WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9 ]")),
          ],
          controller: _conPass,
          focusNode: _conPassNode,
          textInputAction: TextInputAction.done,
          obscureText: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide(color: Theme.of(context).accentColor)),
            labelText: 'Confirm Password',
            hintText: 'Confirm Password',
            prefixIcon: Icon(Icons.enhanced_encryption,
                color: Theme.of(context).primaryColor),
          ),
          validator: (value) {
            if (value.length == 0)
              return 'Please confirm your password.';
            else if (value != _password.text) return 'Passwords do not match!';
          }),
    );
  }

  Widget get _signUpForm {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _nameField,
          _userNameField,
          _passwordField,
          _conPassField,
        ],
      ),
    );
  }

  Widget get _submitButton {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      FlatButton(
          child: Text(
            'Create',
            style: TextStyle(color: Colors.blue, fontSize: 20),
          ),
          onPressed: () => signup())
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Stack(children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _signUpForm,
              _submitButton,
            ],
          ),
          Align(alignment: Alignment.bottomCenter, child: _signUpChoice)
        ]),
      ),
    );
  }
}
