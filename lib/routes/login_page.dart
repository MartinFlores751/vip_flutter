import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:vip_flutter/routes/sign_up.dart';
import 'package:vip_flutter/db_crud.dart';
import 'package:vip_flutter/routes/logged_acc.dart';
import 'package:vip_flutter/routes/logged_accVIP.dart';
import 'package:vip_flutter/user_class.dart';
import 'package:vip_flutter/states/user_state_container.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);
  static const String routeName = '/';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  var _username = TextEditingController();
  var _password = TextEditingController();
  bool isValidating = false;

  Widget mainView;

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
          if (value.length == 0) return 'Please input a valid username!';
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
          if (value.length == 0) return 'Please input a valid password!';
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

  Future<Null> _validateForm() async {
    setState(() {
      isValidating = true;
    });
    if (_formKey.currentState.validate()) {
      Map<String, dynamic> results =
          await doAuthCRUD(_username.text, _password.text);
      if (results['isSuccess']) {
        results['user'].userName = _username.text;
        User arg = results['user'];
        if (results['user'].isHelper) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  UserContainer(user: arg, child: LoggedAcc())));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  UserContainer(user: arg, child: LoggedAccVIP())));
        }
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Field(s) Empty', toastLength: Toast.LENGTH_SHORT);
    }
    setState(() {
      isValidating = false;
    });
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
            MaterialPageRoute(builder: (context) => SignUp(serverURL)),
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
    mainView = isValidating ? CircularProgressIndicator() : _loginForm;

    return Scaffold(
      body: Center(child: mainView),
    );
  }
}
