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
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  FocusNode _usernameFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();
  
  bool isValidating = false;

  Widget mainView;

  Widget get _usernameField {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      width: MediaQuery.of(context).size.width * 0.75,
      child: TextFormField(
        inputFormatters: [
          new WhitelistingTextInputFormatter(new RegExp("[a-zA-Z0-9]")),
        ],
        controller: _username,
        focusNode: _usernameFocus,
        textInputAction: TextInputAction.next,
        decoration: new InputDecoration(
          border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              borderSide: new BorderSide(color: Theme.of(context).accentColor)),
          hintText: 'Username',
          labelText: 'Username',
          prefixIcon: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
          ),
        ),
        validator: (value) {
          if (value.length == 0) return 'Please input a valid username!';
        },
        onEditingComplete: () => FocusScope.of(context).requestFocus(_passwordFocus),
      ),
    );
  }

  Widget get _passwordField {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: TextFormField(
        inputFormatters: [
          new BlacklistingTextInputFormatter(new RegExp("[ ]")),
        ],
        controller: _password,
        focusNode: _passwordFocus,
        textInputAction: TextInputAction.done,
        obscureText: true,
        decoration: new InputDecoration(
            border: new OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                borderSide: new BorderSide(color: Theme.of(context).accentColor)),
            hintText: '******',
            labelText: 'Password',
            prefixIcon: Icon(
              Icons.enhanced_encryption,
              color: Theme.of(context).primaryColor,
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
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text("Login"),
      color: Theme.of(context).primaryColor,
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
        await setStatus(Status.offline);
        client.close();
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
      margin: const EdgeInsets.only(bottom: 7.5),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
          border: Border.all(width: 3, color: Theme.of(context).iconTheme.color)),
      child: _logoIcon,
    );
  }

  Widget get _loginForm {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _logoBox,
          Column(
            children: <Widget>[
              _usernameField,
              _passwordField,
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
