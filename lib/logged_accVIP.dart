import 'package:flutter/material.dart';
import 'settings.dart';

class VipDashboard extends StatelessWidget {
  List<dynamic> allhelpers;
  VipDashboard(this.allhelpers);

  _buildColor(int i)
  {
    if (i == 0)
    {
      return Colors.greenAccent[100];
    }
    else if (i == 1)
    {
      return Colors.yellowAccent[100];
    }
    else
    {
      return Colors.grey[300];
    }
  }
  _buildList(int i, BuildContext context)
  {
    var con = Container(
      height: 180,
      child: Column(
        children: <Widget>[
          Text("${allhelpers[i]}", style: TextStyle(color: Colors.black, fontSize: 40.0, fontWeight: FontWeight.bold)),
          Divider(color: Colors.black,),
          Text("Status: Available", style: TextStyle(fontSize: 20.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(iconSize: 75, color: Colors.purple, icon: Icon(Icons.person_add), onPressed: (){},),
              IconButton(iconSize: 75, color: Colors.blue, icon: Icon(Icons.videocam), onPressed: (){},),
              IconButton(iconSize: 75, color: Colors.red, icon: Icon(Icons.remove_circle), onPressed: (){},),
            ],
          ),
        ],
      )
    );
    return Container(
      foregroundDecoration: true ? null : BoxDecoration(
        color: Colors.grey,
        backgroundBlendMode: BlendMode.saturation,
      ),
      height: MediaQuery.of(context).size.height/2.5,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.0, color: Color(0xFFFF000000)),), color: _buildColor(i)),
      child: ListTile(
      title: Icon(Icons.account_circle, color: Colors.blue, size: 75),
      subtitle: con,
      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      onTap: true ? (){
        print("tapped${i.toString()}");
      }: null,
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: allhelpers.length, //change to total number of helpers
        padding: const EdgeInsets.all(0.0),
        itemBuilder: (context, index) => _buildList(index, context)
      ),
    );
  }
}

class loggedAccVIP extends StatefulWidget {
  String token;
  List<dynamic> allhelpers;
  String uName;

  loggedAccVIP(this.token, this.allhelpers, this.uName);

  _loggedAccVIPState createState() => _loggedAccVIPState(this.token, this.allhelpers, this.uName);
}

class _loggedAccVIPState extends State<loggedAccVIP> {
  String token;
  List<dynamic> allhelpers;
  String uName;

  int _selectedIndex = 0;
  final _widgetOptions = [
    Text('Index 0: Helpers'),
    Text('Index 1: Find New Helpers')];

  _loggedAccVIPState(this.token, this.allhelpers, this.uName);

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
                  Text(uName, style: new TextStyle(fontSize: 20, color: Colors.white),),
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