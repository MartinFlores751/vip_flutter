import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'package:vip_flutter/helper_list.dart';
import 'package:vip_flutter/routes/settings.dart';
import 'package:vip_flutter/states/user_state_container.dart';
import 'package:vip_flutter/db_crud.dart';
import 'package:vip_flutter/user_class.dart';

class LoggedAccVIP extends StatefulWidget {
  static const String routeName = '/vip_home';
  LoggedAccVIP();

  _LoggedAccVIPState createState() => _LoggedAccVIPState();
}

class _LoggedAccVIPState extends State<LoggedAccVIP>
    with WidgetsBindingObserver {
  User user;
  int _selectedIndex = 0;

  // Life cycle for the current widget.
  AppLifecycleState _lastLifecycleState;

  // ------------
  // Widget Stuff
  // ------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Not sure what this does...
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Do we really need to change the state?
    setState(() {
      _lastLifecycleState = state;
    });
  }

  // This is a recursive function that is supposed to count up to 150 before logging the user off...
  // This will get some major refactoring
  void _checkPaused(int i) async {
    // What is i supposed to be?
    if (i == 5) {
      // Going away when phone powered off
      if (_lastLifecycleState == AppLifecycleState.paused ||
          _lastLifecycleState == AppLifecycleState.inactive) {
        debugPrint("Going Away");

        setStatus(
            UserContainer.of(context).state.currentUser.token, Status.away);

        // Firestore stuff...
        Map<String, dynamic> bodyCha = {
          "${user.userName}": {
            "away": true,
            "online": true,
          }
        };
        Firestore.instance
            .collection('Users')
            .document('allUsers')
            .updateData(bodyCha);
        Firestore.instance
            .collection('Users')
            .document('allVip')
            .updateData(bodyCha); //change allVips

        Map<String, String> body = {
          "status": '1',
        };

        // Personal Server Stuff...
        var url = serverURL + "/set_status";
        await http.post(url, body: body);

        // Recursive call
        _checkPaused(i + 1);
      } else {
        print("Resuming");

        setStatus(
            UserContainer.of(context).state.currentUser.token, Status.online);

        // Firebase call
        Map<String, dynamic> bodyCha = {
          "${user.userName}": {
            "away": false,
            "online": true,
          }
        };
        Firestore.instance
            .collection('Users')
            .document('allUsers')
            .updateData(bodyCha);
        Firestore.instance
            .collection('Users')
            .document('allVip')
            .updateData(bodyCha); //change allVips

        Map<String, String> body = {
          "status": '0',
        };

        // Call to personal server...
        var url = serverURL + "/set_status";
        await http.post(url, body: body);
        return;
      }
    }
    // When the count gets up to 150...
    else if (i == 150) {
      // When 150 'ticks' have passed, loggout if still inactive...
      if (_lastLifecycleState == AppLifecycleState.paused ||
          _lastLifecycleState == AppLifecycleState.inactive) {
        print("Logging Out");

        setStatus(
            UserContainer.of(context).state.currentUser.token, Status.offline);

        // Firebase
        final DocumentReference postRef =
            Firestore.instance.collection("Users").document('OnlineCount');
        Firestore.instance.runTransaction((Transaction tx) async {
          DocumentSnapshot postSnapshot = await tx.get(postRef);
          if (postSnapshot.exists) {
            await tx.update(postRef, <String, dynamic>{
              'TotalOnline': postSnapshot.data['TotalOnline'] - 1
            });
            await tx.update(postRef, <String, dynamic>{
              'VipOnline': postSnapshot.data['VipOnline'] - 1
            });
          }
        });
        Map<String, dynamic> bodyCha = {
          "${user.userName}": {
            "away": false,
            "online": false,
          }
        };
        Firestore.instance
            .collection('Users')
            .document('allUsers')
            .updateData(bodyCha);
        Firestore.instance
            .collection('Users')
            .document('allVip')
            .updateData(bodyCha); //change allVips

        // Personal Server
        Map<String, String> body = {
          "status": '2',
        };
        var url = serverURL + "/set_status";
        await http.post(url, body: body);
      }
      // Exit regardless?
      exit(0); // Does this cause the application to shutdown?
    } else {
      // Wait for 2 seconds
      await Future.delayed(Duration(seconds: 2));

      if (_lastLifecycleState == AppLifecycleState.paused ||
          _lastLifecycleState == AppLifecycleState.inactive) {
        _checkPaused(i + 1);
      } else {
        print("Resuming");

        Map<String, dynamic> bodyCha = {
          "${user.userName}": {
            "away": false,
            "online": true,
          }
        };
        Firestore.instance
            .collection('Users')
            .document('allUsers')
            .updateData(bodyCha);
        Firestore.instance
            .collection('Users')
            .document('allVip')
            .updateData(bodyCha); //change allVips

        Map<String, String> body = {
          "status": '0',
        };
        var url = serverURL + "/set_status";
        await http.post(url, body: body);
        return;
      }
    }
  }

  // ----------------------
  // Refactored Bulid Stuff
  // ----------------------
  Widget get _vipAppBar {
    return AppBar(title: Text(''));
  }

  Widget get _lookForHelpers {
    return Scaffold(
      appBar: null,
      body: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('Users')
            .document('allHelpers')
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Align(
                alignment: FractionalOffset(.5, .5),
                child: CircularProgressIndicator(),
              );
            default:
              var a = snapshot.data.data;
              return Container(
                child: HelperList(helpers: a),
              );
          }
        },
      ),
    );
  }

  Widget get _callForHelpButton {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3.3,
      child: new RaisedButton.icon(
        icon: Icon(
          Icons.phone,
          size: 100,
          color: Colors.green,
        ),
        label: Text(
          "Call for Help",
          style: TextStyle(fontSize: 40),
        ),
        color: Colors.green[100],
        elevation: 4.0,
        splashColor: Colors.green,
        onPressed: () {
          debugPrint("This is where help would be called!");
        },
      ),
    );
  }

  Widget get _totalOnlineBlock {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 6,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 2.0, color: Color(0xFF000000)),
          left: BorderSide(width: 2.0, color: Color(0xFF000000)),
          right: BorderSide(width: 2.0, color: Color(0xFF000000)),
          bottom: BorderSide(width: 0.0, color: Color(0xFF000000)),
        ),
      ),
      child: Align(
        alignment: FractionalOffset(.5, .5),
        child: StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .collection('Users')
              .document('OnlineCount')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return CircularProgressIndicator();
              default:
                var a = snapshot.data;
                return Align(
                  alignment: FractionalOffset(.5, .5),
                  child: Text(
                    "Total Online: ${a["TotalOnline"]}",
                    style: TextStyle(fontSize: 25),
                  ),
                );
            }
          },
        ),
      ),
    );
  }

  Widget get _vipCountBlock {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      height: MediaQuery.of(context).size.height / 3,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 2.0, color: Color(0xFF000000)),
          left: BorderSide(width: 2.0, color: Color(0xFF000000)),
          right: BorderSide(width: 0.0, color: Color(0xFF000000)),
          bottom: BorderSide(width: 2.0, color: Color(0xFF000000)),
        ),
      ),
      child: Align(
        alignment: FractionalOffset(.5, .5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "VIP:",
              style: TextStyle(fontSize: 25),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance
                  .collection('Users')
                  .document('OnlineCount')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    var a = snapshot.data;
                    return Align(
                      alignment: FractionalOffset(.5, .5),
                      child: Text(
                        "${a["VipOnline"]}",
                        style: TextStyle(fontSize: 50),
                      ),
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget get _helperCountBlock {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      height: MediaQuery.of(context).size.height / 3,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
      ),
      child: Align(
        alignment: FractionalOffset(.5, .5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Helpers:",
              style: TextStyle(fontSize: 25),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance
                  .collection('Users')
                  .document('OnlineCount')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    var a = snapshot.data;
                    return Align(
                      alignment: FractionalOffset(.5, .5),
                      child: Text(
                        "${a["HelpersOnline"]}",
                        style: TextStyle(fontSize: 50),
                      ),
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // This needs to be modified because it's overflowing!
  Widget get _vipHome {
    return Container(
      child: Column(
        children: <Widget>[
          _callForHelpButton,
          _totalOnlineBlock,
          Row(
            children: <Widget>[_vipCountBlock, _helperCountBlock],
          ),
        ],
      ),
    );
  }

  // Build what?
  Widget get _buildSelectedPage {
    if (_selectedIndex == 1) {
      return _lookForHelpers;
    } else {
      return _vipHome;
    }
  }

  Widget get vipDrawer {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        children: <Widget>[
          DrawerHeader(
            child: Row(
              children: [
                _accountIcon,
                Text(
                  user.userName,
                  style: new TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Log Out'),
            onTap: () {
              setStatus(UserContainer.of(context).state.currentUser.token,
                  Status.offline);

              final DocumentReference postRef = Firestore.instance
                  .collection("Users")
                  .document('OnlineCount');
              Firestore.instance.runTransaction((Transaction tx) async {
                DocumentSnapshot postSnapshot = await tx.get(postRef);
                if (postSnapshot.exists) {
                  await tx.update(postRef, <String, dynamic>{
                    'TotalOnline': postSnapshot.data['TotalOnline'] - 1
                  });
                  await tx.update(postRef, <String, dynamic>{
                    'VipOnline': postSnapshot.data['VipOnline'] - 1
                  });
                }
                Map<String, dynamic> body = {
                  "${user.userName}": {
                    "away": false,
                    "online": false,
                  }
                };
                Firestore.instance
                    .collection('Users')
                    .document('allUsers')
                    .updateData(body);
                Firestore.instance
                    .collection('Users')
                    .document('allVip')
                    .updateData(body); //Change to allVips
              });
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Preferences'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccSettings()),
              );
            },
          )
        ],
      ),
    );
  }

  Widget get _accountIcon {
    return IconButton(
        icon: Icon(Icons.account_box),
        color: Colors.white,
        iconSize: 80,
        onPressed: () {
          //show account information?
        });
  }

  void _navBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget get _vipNavBar {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.visibility), title: Text('Get Help')),
        BottomNavigationBarItem(
            icon: Icon(Icons.search), title: Text('Look For New Helpers')),
      ],
      currentIndex: _selectedIndex,
      fixedColor: Colors.blueGrey,
      onTap: _navBarTapped,
    );
  }

  @override
  Widget build(BuildContext context) {
    user = UserContainer.of(context).state.currentUser;

    // Put this into a seperate function that'll handle states better
    if (_lastLifecycleState != null) {
      switch (_lastLifecycleState) {
        case AppLifecycleState.resumed:
          debugPrint("Resumed"); //App Resumed
          break;
        case AppLifecycleState.inactive:
          debugPrint("Inactive");
          _checkPaused(0); //THIS ONE OR
          break;
        case AppLifecycleState.paused:
          debugPrint("Paused");
          _checkPaused(0); //THIS ONE
          break;
        case AppLifecycleState.suspending:
          debugPrint("Logging out");
          setStatus(UserContainer.of(context).state.currentUser.token,
              Status.offline);
          break;
        default:
          debugPrint("Don't care");
          break;
      }
    }

    // Here's the "actual" app
    return Scaffold(
      appBar: _vipAppBar,
      body: _buildSelectedPage,
      drawer: vipDrawer,
      bottomNavigationBar: _vipNavBar,
    );
  }
}
