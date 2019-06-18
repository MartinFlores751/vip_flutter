import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vip_flutter/db_crud.dart';

import 'package:vip_flutter/firestore_stuff.dart';
import 'package:vip_flutter/stats_card.dart';

import 'package:vip_flutter/routes/settings.dart';
import 'package:vip_flutter/states/user_state_container.dart';
import 'package:vip_flutter/user_class.dart';

//TODO: Move LoginStatistics and VIPQueue in their own helper files
//TODO: Add calls to WebRTC in UserContainer
class LoginStatistics extends StatefulWidget {
  @override
  _LoginStatisticsState createState() => _LoginStatisticsState();
}

class _LoginStatisticsState extends State<LoginStatistics>
    with WidgetsBindingObserver {
  bool animateLogCardOne = false;
  bool animateLogCardTwo = false;
  void beginOne() => setState(() => animateLogCardOne = true);
  void beginTwo() => setState(() => animateLogCardTwo = true);

  @override
  Widget build(BuildContext context) {
    Widget spaceFormat = SizedBox(
      height: MediaQuery.of(context).size.height * .025,
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StatsCard(
            title: "Total Online",
            titleColor: Colors.blue,
            callBack: beginOne,
            whoToShow: 'TotalOnline',
          ),
          spaceFormat,
          animateLogCardOne
              ? StatsCard(
                  title: "VIP Online",
                  titleColor: Colors.redAccent,
                  callBack: beginTwo,
                  whoToShow: 'VipOnline',
                )
              : Container(height: MediaQuery.of(context).size.height * .23),
          spaceFormat,
          animateLogCardTwo
              ? StatsCard(
                  title: "Helpers Online",
                  titleColor: Colors.green,
                  callBack: () {},
                  whoToShow: 'HelpersOnline',
                )
              : Container(height: MediaQuery.of(context).size.height * .23),
        ],
      ),
    );
  }
}

class VIPQueue extends StatefulWidget {
  @override
  _VIPQueueState createState() => _VIPQueueState();
}

class _VIPQueueState extends State<VIPQueue> {
  @override
  Widget build(BuildContext context) {
    return Container(child: streamForVIPsOnline());
  }
}

class LoggedAcc extends StatefulWidget {
  static const String routeName = '/helper_home';
  LoggedAcc();
  _LoggedAccState createState() => _LoggedAccState();
}

class _LoggedAccState extends State<LoggedAcc> with WidgetsBindingObserver {
  User user;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Not sure what this does...
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // UserContainer.of(context).initRenderers(); // Create the rendering objects!
    // UserContainer.of(context).connect(); // Connect to the signalling server
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        //firestoreRunTransaction(-1, 'HelpersOnline');
        firestoreUpdateVIP(user.userName, true, true, 'allHelpers');
        setStatus(Status.away);
        break;
      case AppLifecycleState.resumed:
        firestoreRunTransaction(1, 'HelpersOnline');
        firestoreUpdateVIP(user.userName, false, true, 'allHelpers');
        setStatus(Status.online);
        break;
      case AppLifecycleState.suspending:
        //firestoreRunTransaction(-1, 'HelpersOnline');
        firestoreUpdateVIP(user.userName, false, false, 'allHelpers');
        setStatus(Status.offline);
        break;
      case AppLifecycleState.paused:
        firestoreRunTransaction(-1, 'HelpersOnline');
        firestoreUpdateVIP(user.userName, true, true, 'allHelpers');
                setStatus(Status.away);
        break;
    }
  }

  List<Widget> navBarPages = [
    LoginStatistics(),
    VIPQueue(),
  ];

  @override
  Widget build(BuildContext context) {
    user = UserContainer.of(context).state.currentUser;
    var accIcon = IconButton(
        icon: Icon(Icons.account_box),
        color: Colors.white,
        iconSize: 80,
        onPressed: () {
          //show account information?
        });

    void onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text('')),
      //add a body
      body: navBarPages[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          children: <Widget>[
            DrawerHeader(
              child: Row(
                children: [
                  accIcon,
                  Text(
                    '${user.userName}',
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
                firestoreRunTransaction(-1, 'HelpersOnline');
                firestoreUpdateVIP(user.userName, false, false, 'allHelpers');
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.visibility), title: Text('Login Statistics')),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), title: Text('VIP in queue')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.blueGrey,
        onTap: onItemTapped,
      ),
    );
  }
}
