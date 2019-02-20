import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'user_class.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';

class signUp extends StatefulWidget {
  _signUpState createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  var _fullName = TextEditingController();
  var _userName = TextEditingController();
  var _password = TextEditingController();
  var _conPass = TextEditingController();
  var url = "localhost:4567/register_users";
  int _rValue1 = -1;

  void _handleValue1(int value)
  {
    setState((){
      _rValue1 = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var radio = new Column(
      children: <Widget>[
        Text('Helper:', style: TextStyle(fontSize: 17),),
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
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          width: 160,
          height: 50,
          child: TextFormField(
            controller: _fullName,
            autofocus: false,
            obscureText: false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
              //border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelText: 'FullName'
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          width: 160,
          height: 50,
          child: TextFormField(
            controller: _userName,
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
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          width: 160,
          height: 50,
          child: TextFormField(
            controller: _conPass,
            autofocus: false,
            obscureText: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
              //border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelText: 'Confirm Pass.'
            ),
          ),
        ),
      ],
    );

    var created = new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlatButton(
          child: Text(
            'Create',
            style: TextStyle(color: Colors.blue, fontSize: 20),
          ),
          onPressed: () {
            if (_userName.text.isNotEmpty && _fullName.text.isNotEmpty && _password.text.isNotEmpty && _conPass.text.isNotEmpty && _rValue1 >= 0)
            {
              if (_conPass.text == _password.text)
              {
                User u = new User();
                u.fullName = _fullName.text;
                u.userName = _userName.text;
                u.password = _password.text;
                u.conPass = _conPass.text;
                u.helper = _rValue1;
                http.post(url, body: {'name': u.fullName, 'user': u.userName,'helper': u.helper,
                                          'password': u.password, 'c_password': u.conPass});
                Navigator.pop(context);
              }
              else
              {
                Fluttertoast.showToast(msg: 'Passwords dont match',toastLength: Toast.LENGTH_SHORT);
              }
            }
            else
            {
              Fluttertoast.showToast(msg: 'Field(s) empty',toastLength: Toast.LENGTH_SHORT);
            }
          },
        )
      ]
    );


    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(''),
      ),
      body: new Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[signUpCredentials, created],
          ),
        ),
      ),
    );
  }
}