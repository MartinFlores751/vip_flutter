/*
 * Copyright (C) 2019. The AUTHORS - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
 */

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:vip_flutter/routes/logged_acc.dart';
import 'package:vip_flutter/routes/logged_accVIP.dart';
import 'package:vip_flutter/routes/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
        title: 'VIP Flutter',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        initialRoute: LoginPage.routeName,
        routes: {
          LoginPage.routeName: (context) => LoginPage(),
          LoggedAcc.routeName: (context) => LoggedAcc(),
          LoggedAccVIP.routeName: (context) => LoggedAccVIP()
        });
  }
}
