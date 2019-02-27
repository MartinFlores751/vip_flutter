import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
            Map<String, String> body = {
              'name': _fullName.text,
              'user': _userName.text,
              'helper': _rValue1.toString(),
              'password': _password.text,
              'c_password': _conPass.text,
            };
            var url = "https://vip-serv.herokuapp.com//register_user"; //change ip and port as needed
            http.post(url, body: body)
              .then((response) {
                if (response.statusCode == 200)
                {
                  Fluttertoast.showToast(msg: '${response.body}',toastLength: Toast.LENGTH_SHORT);
                  print("Response status: ${response.statusCode}");
                  print("Response body: ${response.body}");
                }
                else
                {
                  Fluttertoast.showToast(msg: 'Connection Failed',toastLength: Toast.LENGTH_SHORT);
                }
              }
            );
            Navigator.pop(context);
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