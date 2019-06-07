import 'package:flutter/material.dart';

import 'package:vip_flutter/routes/settings.dart';

// TODO: Remove demo code
class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.blue, size: 75),
            title: Text("Helper One"),
            subtitle: Text("Status: Available"),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          ),
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.blue, size: 75),
            title: Text("Helper Two"),
            subtitle: Text("Status: Unavailable"),
            enabled: false,
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          ),
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.blue, size: 75),
            title: Text("Helper Three"),
            subtitle: Text("Status: Unavailable"),
            enabled: false,
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          ),
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.blue, size: 75),
            title: Text("Helper Four"),
            subtitle: Text("Status: Available"),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          )
        ],
      ),
    );
  }
}

class LoggedAcc extends StatefulWidget {
  static const String routeName = '/helper_home';
  LoggedAcc();
  _LoggedAccState createState() => _LoggedAccState();
}

class _LoggedAccState extends State<LoggedAcc> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var accIcon = IconButton(
        icon: Icon(Icons.account_box),
        color: Colors.white,
        iconSize: 80,
        onPressed: () {
          //show account information?
        });

    void onItemTapped(int index) {
      setState(() {
        selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text('')),
      //add a body
      body: UserDashboard(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          children: <Widget>[
            DrawerHeader(
              child: Row(
                children: [
                  accIcon,
                  Text(
                    'Account Name',
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
              icon: Icon(Icons.visibility), title: Text('Helpers')),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), title: Text('Look For New Helpers')),
        ],
        currentIndex: selectedIndex,
        fixedColor: Colors.blueGrey,
        onTap: onItemTapped,
      ),
    );
  }
}
