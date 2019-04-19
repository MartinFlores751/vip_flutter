import 'package:flutter/material.dart';
import 'settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';

class VipDashboard extends StatefulWidget {
  List<dynamic> allhelpers;
  VipDashboard(this.allhelpers);
  @override
  _VipDashboardState createState() => _VipDashboardState(allhelpers);
}

class _VipDashboardState extends State<VipDashboard> {
  List<dynamic> allhelpers;
  _VipDashboardState(this.allhelpers);
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
  _buildList(int i, BuildContext context, var a)
  {
    var con = Container(
      height: 180,
      child: Column(
        children: <Widget>[
          Text("${a.keys.elementAt(i)}", style: TextStyle(color: Colors.black, fontSize: 40.0, fontWeight: FontWeight.bold)),
          Divider(color: Colors.black,),
          a[a.keys.elementAt(i)]['away'] ? 
            Text("Status: Away", style: TextStyle(fontSize: 20.0)) : (
              a[a.keys.elementAt(i)]['online'] ? Text("Status: Available", style: TextStyle(fontSize: 20.0)) : 
              Text("Status: Offline", style: TextStyle(fontSize: 20.0))
          ),
            
          //Text("Status: Available", style: TextStyle(fontSize: 20.0)),
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
      foregroundDecoration: a[a.keys.elementAt(i)]['online'] ? null : BoxDecoration(
        color: Colors.grey,
        backgroundBlendMode: BlendMode.saturation,
      ),
      height: MediaQuery.of(context).size.height/2.5,
      decoration: a[a.keys.elementAt(i)]['online'] ? 
        BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1.0,
              color: Color(0xFFFF000000)
            ),
          ),
          color: a[a.keys.elementAt(i)]['away'] ? _buildColor(1) : _buildColor(0),
        ) : BoxDecoration(border: Border(bottom: BorderSide(width: 1.0, color: Color(0xFFFF000000)),), color: _buildColor(2)),
      child: ListTile(
        title: Icon(Icons.account_circle, color: Colors.blue, size: 75),
        subtitle: con,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        onTap: true ? (){
          
        }: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('Users').document('allHelpers').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new Text('Loading...');
          default:
            var a = snapshot.data.data;
            return Container(
              child: ListView.builder(
                itemCount: a.length,
                padding: const EdgeInsets.all(0.0),
                itemBuilder: (context, index) => _buildList(index, context, a)
              ),
            );
        }
      },
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

class _loggedAccVIPState extends State<loggedAccVIP> with WidgetsBindingObserver{
  String token;
  List<dynamic> allhelpers;
  String uName;

  String urlBase = "https://vip-serv.herokuapp.com/api";
  int _selectedIndex = 0;
  final _widgetOptions = [
    Text('Index 0: Helpers'),
    Text('Index 1: Find New Helpers')];

  _loggedAccVIPState(this.token, this.allhelpers, this.uName);

  AppLifecycleState _lastLifecycleState;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });
  }
  void checkPaused(int i) async
  {
    if(i == 5)
    {
      if (_lastLifecycleState.index == 2 || _lastLifecycleState.index == 1){
        print("Going Away");

        Map<String, dynamic> bodyCha = {
          "$uName":{
            "away": true,
            "online": true,
          }
        };
        Firestore.instance.collection('Users').document('allUsers').updateData(bodyCha);
        Firestore.instance.collection('Users').document('allVip').updateData(bodyCha); //change allVips

        Map<String, String> body ={
          "status": '1',
        };
        var url = urlBase + "/set_status";
        var response = await http.post(url, body: body);
        checkPaused(i+1);
      }
      else{
        print("Resuming");

        Map<String, dynamic> bodyCha = {
          "$uName":{
            "away": false,
            "online": true,
          }
        };
        Firestore.instance.collection('Users').document('allUsers').updateData(bodyCha);
        Firestore.instance.collection('Users').document('allVip').updateData(bodyCha); //change allVips

        Map<String, String> body={
          "status": '0',
        };
        var url = urlBase +"/set_status";
        var response = await http.post(url, body: body);
        return;
      }
    }
    else if(i == 150){
      if (_lastLifecycleState.index == 2 || _lastLifecycleState.index == 1){
        print("Logging Out");

        final DocumentReference postRef = Firestore.instance.collection("Users").document('OnlineCount');
        Firestore.instance.runTransaction((Transaction tx) async {
          DocumentSnapshot postSnapshot = await tx.get(postRef);
          if (postSnapshot.exists) {
            await tx.update(postRef, <String, dynamic>{'TotalOnline': postSnapshot.data['TotalOnline'] - 1});
            await tx.update(postRef, <String, dynamic>{'VipOnline': postSnapshot.data['VipOnline'] - 1});
          }
        });
        Map<String, dynamic> bodyCha = {
          "$uName":{
            "away": false,
            "online": false,
          }
        };
        Firestore.instance.collection('Users').document('allUsers').updateData(bodyCha);
        Firestore.instance.collection('Users').document('allVip').updateData(bodyCha); //change allVips

        Map<String, String> body={
          "status": '2',
        };
        var url = urlBase +"/set_status";
        var response = await http.post(url, body: body);
      }
      exit(0);
    }
    else
    {
      await Future.delayed(Duration(seconds: 2));
      print(_lastLifecycleState);
      if (_lastLifecycleState.index == 2 || _lastLifecycleState.index == 1)
      {
        checkPaused(i+1);
      }
      else{
        print("Resuming");

        Map<String, dynamic> bodyCha = {
          "$uName":{
            "away": false,
            "online": true,
          }
        };
        Firestore.instance.collection('Users').document('allUsers').updateData(bodyCha);
        Firestore.instance.collection('Users').document('allVip').updateData(bodyCha); //change allVips

        Map<String, String> body={
          "status": '0',
        };
        var url = urlBase +"/set_status";
        var response = await http.post(url, body: body);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_lastLifecycleState);
    if (_lastLifecycleState != null){
      switch(_lastLifecycleState.index)
      {
        case 0:
          print("Resumed"); //App Resumed
          break;
        case 1:
          print("Inactive");
          checkPaused(0); //THIS ONE OR
          break;
        case 2:
          print("Paused");
          checkPaused(0); //THIS ONE
          break;
      }
    }

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

    _buildSomething(){
      if (_selectedIndex == 1){
        return VipDashboard(allhelpers);
      }
      else{
        return StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.collection('Users').document('OnlineCount').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting: return new Text('Loading...');
              default:
                var a = snapshot.data;
                return Align(
                  alignment: FractionalOffset(0, .0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/3-1,
                        child: new RaisedButton.icon(
                          icon: Icon(Icons.phone, size: 100, color: Colors.green,),
                          label: Text("Call for Help", style: TextStyle(fontSize: 40),),
                          color: Colors.green[100],
                          elevation: 4.0,
                          splashColor: Colors.green,
                          onPressed: () {
                            // Perform some action
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/6,
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
                          child: Text("Total Online: ${a["TotalOnline"]}", style: TextStyle(fontSize: 25),),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width/2,
                            height: MediaQuery.of(context).size.height/3-20,
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
                                  Text("VIP:", style: TextStyle(fontSize: 25),),
                                  Text("${a["VipOnline"]}", style: TextStyle(fontSize: 50),),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width/2,
                            height: MediaQuery.of(context).size.height/3-20,
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
                                  Text("Helpers:", style: TextStyle(fontSize: 25),),
                                  Text("${a["HelpersOnline"]}", style: TextStyle(fontSize: 50),),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
            }
          },
        );
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text('')),
      //add a body
      body: _buildSomething(),
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
                final DocumentReference postRef = Firestore.instance.collection("Users").document('OnlineCount');
                Firestore.instance.runTransaction((Transaction tx) async {
                  DocumentSnapshot postSnapshot = await tx.get(postRef);
                  if (postSnapshot.exists) {
                    await tx.update(postRef, <String, dynamic>{'TotalOnline': postSnapshot.data['TotalOnline'] - 1});
                    await tx.update(postRef, <String, dynamic>{'VipOnline': postSnapshot.data['VipOnline'] - 1});
                  }
                  Map<String, dynamic> body = {
                    "$uName":{
                      "away": false,
                      "online": false,
                    }
                  };
                  Firestore.instance.collection('Users').document('allUsers').updateData(body);
                  Firestore.instance.collection('Users').document('allVip').updateData(body); //Change to allVips
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
      ),
      bottomNavigationBar: BottomNavigationBar(
       items: <BottomNavigationBarItem>[
         BottomNavigationBarItem(icon: Icon(Icons.visibility), title: Text('Get Help')),
         BottomNavigationBarItem(icon: Icon(Icons.search), title: Text('Look For New Helpers')),
       ],
       currentIndex: _selectedIndex,
       fixedColor: Colors.blueGrey,
       onTap: _onItemTapped,
      ),
    );
  }
}