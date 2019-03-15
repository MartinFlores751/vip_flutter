import 'package:flutter/material.dart';
import 'settings.dart';

class VipDashboard extends StatelessWidget {
  List<dynamic> allhelpers;
  VipDashboard(this.allhelpers);

  _buildList(int i)
  {
    var con = Container(
      child: Column(
        children: <Widget>[
          Divider(color: Colors.black,),
          Text("Status: Available", style: TextStyle(fontSize: 20.0)),
          Row(children: <Widget>[
              IconButton(iconSize: 50, color: Colors.blue, icon: Icon(Icons.person_add), onPressed: (){},),
              IconButton(iconSize: 50, color: Colors.blue, icon: Icon(Icons.videocam), onPressed: (){},),
              IconButton(iconSize: 50, color: Colors.red, icon: Icon(Icons.remove_circle), onPressed: (){},),
            ],
          ),
        ],
      )
    );
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.0, color: Color(0xFFFF000000)),)),
      child: ListTile(
      leading: Icon(Icons.account_circle, color: Colors.blue, size: 75),
      title: Text("${allhelpers[i]}", style: TextStyle(fontSize: 25.0)),
      subtitle: con,
      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      onTap: (){

      }
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: allhelpers.length, //change to total number of helpers
        padding: const EdgeInsets.all(0.0),
        itemBuilder: (context, index) => _buildList(index)
      ),
    );
  }
}

class loggedAccVIP extends StatefulWidget {
  String token;
  List<dynamic> allhelpers;

  loggedAccVIP(this.token, this.allhelpers);

  _loggedAccVIPState createState() => _loggedAccVIPState(this.token, this.allhelpers);
}

class _loggedAccVIPState extends State<loggedAccVIP> {
  String token;
  List<dynamic> allhelpers;

  int _selectedIndex = 0;
  final _widgetOptions = [
    Text('Index 0: Helpers'),
    Text('Index 1: Find New Helpers')];

  _loggedAccVIPState(this.token, this.allhelpers);

  @override
  Widget build(BuildContext context) {
    var accIcon = IconButton(
      icon: Icon(Icons.account_box),
      color: Colors.white,
      iconSize: 80,
      onPressed: () {
        //show account information?
      }
    );
    
    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text('')),
      //add a body
      body: VipDashboard(allhelpers),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          children: <Widget>[
            DrawerHeader(
              child: Row(
                children: [accIcon,
                  Text('Account Name', style: new TextStyle(fontSize: 20, color: Colors.white),),
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
         BottomNavigationBarItem(icon: Icon(Icons.visibility), title: Text('Helpers')),
         BottomNavigationBarItem(icon: Icon(Icons.search), title: Text('Look For New Helpers')),
       ],
       currentIndex: _selectedIndex,
       fixedColor: Colors.blueGrey,
       onTap: _onItemTapped,
      ),
    );
  }
}