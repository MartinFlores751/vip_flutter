import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class signUp extends StatefulWidget {
  _signUpState createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  var _fullName = TextEditingController();
  var _userName = TextEditingController();
  var _password = TextEditingController();
  var _conPass = TextEditingController();
  int _rValue1 = -1;

  void _handleValue1(int value)
  {
    setState((){
      _rValue1 = value;
    });
  }

  Future<dynamic> connect() async{
    if (_fullName.text.length == 0 || _userName.text.length == 0 || _rValue1 == -1 || _password.text.length == 0 || _conPass.text.length == 0)
    {
      return null;
    }
    Map<String, String> body = {
      'name': _fullName.text,
      'user': _userName.text,
      'helper': _rValue1.toString(),
      'password': _password.text,
      'c_password': _conPass.text,
    };
    var url = "https://vip-serv.herokuapp.com/api/register_user";
    var response = await http.post(url, body: body);
    return response;
  }

  void signup() async{
    var response = await connect();
    if (response == null)
    {
      Fluttertoast.showToast(msg: 'Field(s) Empty',toastLength: Toast.LENGTH_SHORT);
      return;
    }
    Fluttertoast.showToast(msg: '${response.body}',toastLength: Toast.LENGTH_SHORT);
    if (response.body == "Account Created!"){
      Navigator.pop(context);
    }
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
            inputFormatters: [
              new WhitelistingTextInputFormatter(new RegExp("[a-zA-Z ]")),
            ],
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
            inputFormatters: [
              new WhitelistingTextInputFormatter(new RegExp("[a-zA-Z0-9]")),
            ],
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
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
            signup();
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