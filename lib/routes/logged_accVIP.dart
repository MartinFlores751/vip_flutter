import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'package:vip_flutter/firestore_stuff.dart';
import 'package:vip_flutter/routes/call_prompt.dart';

import 'package:vip_flutter/routes/settings.dart';
import 'package:vip_flutter/states/user_state_container.dart';
import 'package:vip_flutter/db_crud.dart';
import 'package:vip_flutter/user_class.dart';

import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';

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
    _navigationController.dispose();
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

        setStatus(Status.away);

        // Firestore stuff...
        firestoreUpdateVIP(user.userName, true, true, 'allVip');

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

        setStatus(Status.online);

        // Firebase call
        firestoreUpdateVIP(user.userName, false, true, 'allVip');

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

        setStatus(Status.offline);

        // Firebase
        firestoreRunTransaction(-1, 'VipOnline');
        firestoreUpdateVIP(user.userName, false, false, 'allVip');

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

        firestoreUpdateVIP(user.userName, false, true, 'allVip');

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
      body: streamForHelpersOnline(),
    );
  }

  Widget get _callForHelpButton {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3.36,
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
          setState(() {
            frosted = true;
          });
          debugPrint("This is where help would be called!");
          UserContainer.of(context).callAnyUser();
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
        child: streamsForOnlineBlocks(true, 'TotalOnline', 25),
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
            streamsForOnlineBlocks(false, 'VipOnline', 50),
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
            streamsForOnlineBlocks(false, 'HelpersOnline', 50),
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
              firestoreRunTransaction(-1, 'VipOnline');
              firestoreUpdateVIP(user.userName, false, false, 'allVip');

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

  static int selectedPos = 0;
  double bottomNavBarHeight = 60;
  CircularBottomNavigationController _navigationController =
      new CircularBottomNavigationController(selectedPos);
  List<TabItem> tabItems = List.of([
    new TabItem(Icons.visibility, "Get Help", Colors.black),
    new TabItem(Icons.search, "Look For New Helpers", Colors.black),
  ]);

  Widget get _vipNavBar {
    return CircularBottomNavigation(
      tabItems,
      selectedIconColor: _selectedIndex == 0 ? Colors.blue : Colors.orange,
      normalIconColor: _selectedIndex == 0 ? Colors.orange : Colors.blue,
      controller: _navigationController,
      barHeight: bottomNavBarHeight,
      barBackgroundColor: Colors.white,
      animationDuration: Duration(milliseconds: 300),
      selectedCallback: (int selectedPos) {
        setState(() {
          this._selectedIndex = selectedPos;
        });
      },
    );
  }

  void frostedOff() {
    setState(() {
      frosted = false;
    });
  }

  bool frosted = false;
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
          setStatus(Status.offline);
          break;
        default:
          debugPrint("Don't care");
          break;
      }
    }

    // Here's the "actual" app
    return Scaffold(
      appBar: frosted ? null : _vipAppBar,
      body: Stack(
        children: <Widget>[
          _buildSelectedPage,
          Align(alignment: Alignment.bottomCenter, child: _vipNavBar),
          frosted
              ? OutgoingCall(frost: frostedOff)
              : Container(
                  width: 0,
                  height: 0,
                )
        ],
      ),
      drawer: vipDrawer,
    );
  }
}
