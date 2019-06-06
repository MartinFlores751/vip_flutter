import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  final String urlBase;
  SignUp(this.urlBase);
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var _fullName = TextEditingController();
  var _userName = TextEditingController();
  var _password = TextEditingController();
  var _conPass = TextEditingController();
  int _rValue1 = -1;

  void _handleValue1(int value) {
    setState(() {
      _rValue1 = value;
    });
  }

  Future<dynamic> connect() async {
    String udid = await FlutterUdid.consistentUdid;
    if (_fullName.text.length == 0 ||
        _userName.text.length == 0 ||
        _rValue1 == -1 ||
        _password.text.length == 0 ||
        _conPass.text.length == 0) {
      return null;
    }
    Map<String, String> body = {
      'name': _fullName.text,
      'user': _userName.text,
      'helper': _rValue1.toString(),
      'password': _password.text,
      'c_password': _conPass.text,
      'UUID': udid,
    };
    var url = widget.urlBase + "/register_user";
    var response = await http.post(url, body: body);
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
      if (_rValue1 == 1) {
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

  @override
  Widget build(BuildContext context) {
    var radio = new Column(
      children: <Widget>[
        Text(
          'Helper:',
          style: TextStyle(fontSize: 17),
        ),
        new Center(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Yes'),
              Radio(
                value: 1,
                groupValue: _rValue1,
                onChanged: _handleValue1,
              ),
              Text('No'),
              Radio(
                value: 0,
                groupValue: _rValue1,
                onChanged: _handleValue1,
              ),
            ],
          ),
        ),
      ],
    );
    var signUpCredentials = new Column(
      children: [
        radio,
        Container(
          //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          width: 160,
          height: 50,
          child: TextFormField(
            inputFormatters: [
              new WhitelistingTextInputFormatter(new RegExp("[a-zA-Z ]")),
            ],
            controller: _fullName,
            autofocus: false,
            obscureText: false,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                //border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                labelText: 'FullName'),
          ),
        ),
        Container(
          //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          width: 160,
          height: 50,
          child: TextFormField(
            inputFormatters: [
              new WhitelistingTextInputFormatter(new RegExp("[a-zA-Z0-9]")),
              LengthLimitingTextInputFormatter(10),
            ],
            controller: _userName,
            autofocus: false,
            obscureText: false,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                //border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                labelText: 'Username'),
          ),
        ),
        Container(
          //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                labelText: 'Password'),
          ),
        ),
        Container(
          //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          width: 160,
          height: 50,
          child: TextFormField(
            inputFormatters: [
              new BlacklistingTextInputFormatter(new RegExp("[ ]")),
            ],
            controller: _conPass,
            autofocus: false,
            obscureText: true,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                //border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                labelText: 'Confirm Pass.'),
          ),
        ),
      ],
    );

    var created =
        new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      FlatButton(
        child: Text(
          'Create',
          style: TextStyle(color: Colors.blue, fontSize: 20),
        ),
        onPressed: () {
          signup();
        },
      )
    ]);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(''),
      ),
      body: new Container(
        //alignment: FractionalOffset(.5, .5),
        child: Align(
          alignment: FractionalOffset(.5, .5),
          //padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              signUpCredentials,
              created
            ],
          ),
        ),
      ),
    );
  }
}
