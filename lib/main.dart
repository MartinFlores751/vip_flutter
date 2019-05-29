/*
 * Copyright (C) 2019. The AUTHORS - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:vip_flutter/sign_up.dart';
import 'package:vip_flutter/go_login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
        title: 'VIP Flutter',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        initialRoute: MyHomePage.routeName,
        routes: {
          MyHomePage.routeName: (context) => MyHomePage(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  static const routeName = '/';

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  var _username = TextEditingController();
  var _password = TextEditingController();
  String urlBase = "https://vip-serv.herokuapp.com/api";

  Widget get _usernameField {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      width: MediaQuery.of(context).size.width / 1.5,
      child: TextFormField(
        inputFormatters: [
          new WhitelistingTextInputFormatter(new RegExp("[a-zA-Z0-9]")),
        ],
        controller: _username,
        autofocus: false,
        obscureText: false,
        textInputAction: TextInputAction.next,
        decoration: new InputDecoration(
          border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              borderSide: new BorderSide(color: Colors.teal)),
          hintText: 'Username',
          labelText: 'Username',
          prefixIcon: const Icon(
            Icons.person,
            color: Colors.blue,
          ),
          prefixText: ' ',
        ),
        validator: (value) {
          if(value.length == 0)
            return 'Please input a valid username!';
        },
      ),
    );
  }

  Widget get _passwordField {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      width: MediaQuery.of(context).size.width / 1.5,
      child: TextFormField(
        inputFormatters: [
          new BlacklistingTextInputFormatter(new RegExp("[ ]")),
        ],
        controller: _password,
        obscureText: true,
        decoration: new InputDecoration(
            border: new OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                borderSide: new BorderSide(color: Colors.teal)),
            hintText: '******',
            labelText: 'Password',
            prefixIcon: const Icon(
              Icons.enhanced_encryption,
              color: Colors.blue,
            ),
            suffixStyle: const TextStyle(color: Colors.green)),
        validator: (value) {
          if (value.length == 0)
            return 'Please input a valid password!';
        },
      ),
    );
  }

  Widget get _loginButton {
    return RaisedButton(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text("Login"),
      color: Colors.blue[200],
      onPressed: _validateForm,
    );
  }

  void _validateForm() {
    if (_formKey.currentState.validate()) {
      // Do FireBase connection stuff here!
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => GoLogin(username: _username.text, password: _password.text)),
      );
    } else {
      Fluttertoast.showToast(
          msg: 'Field(s) Empty', toastLength: Toast.LENGTH_SHORT);
    }
  }

  Widget get _newUserText {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
    ]);
  }

  Widget get _logoIcon {
    return Icon(
      Icons.camera,
      size: 90,
    );
  }

  Widget get _logoBox {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(width: 5, color: Colors.black)),
      child: _logoIcon,
    );
  }

  Widget get _loginForm {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _logoBox,
          SizedBox(height: 15),
          Column(
            children: <Widget>[
              _usernameField,
              SizedBox(
                height: 10,
              ),
              _passwordField
            ],
          ),
          _loginButton,
          _newUserText
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _loginForm),
    );
  }
}
