import 'package:flutter/material.dart';

class User {
  int userId;
  int id;
  var fullName = TextEditingController();
  var userName = TextEditingController();
  var password = TextEditingController();
  var conPass = TextEditingController();
  var helper;

  User({this.userId, this.id, this.fullName, this.userName, this.password, this.conPass, this.helper});
}