import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_webrtc/webrtc.dart';
import 'package:vip_flutter/helper_list.dart';

import 'package:vip_flutter/routes/settings.dart';
import 'package:vip_flutter/webrtc_components/signaling.dart';

class LoggedAccVIP extends StatefulWidget {
  static const String routeName = '/vip_home';
  LoggedAccVIP();

  _LoggedAccVIPState createState() => _LoggedAccVIPState();
}

class _LoggedAccVIPState extends State<LoggedAccVIP>
    with WidgetsBindingObserver {
  List<String> args;
  String urlBase = "https://vip-serv.herokuapp.com/api";
  int _selectedIndex = 0;

  // Life cycle for the current widget.
  AppLifecycleState _lastLifecycleState;

  // ------------
  // WebRTC Stuff
  // ------------

  // TODO: Move the WebRTC stuff into a global class state that is above both logged_accs

  final String serverIP = "129.113.228.50"; //Use Webrtc
  bool _inCalling = false; //Use Webrtc
  Signaling _signaling; //Use Webrtc
  var _selfId; //Use Webrtc
  List<dynamic> _peers; //Use Webrtc
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer(); //Use Webrtc
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer(); //Use Webrtc

  // Create the two renderers for the VIP
  initRenderers() async {
    // Only one of these are needed!
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  // When the Widget gets closed
  @override
  deactivate() {
    super.deactivate();
    if (_signaling != null) _signaling.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void _connect() async {
    // If not signalling to the server, perform setup
    if (_signaling == null) {
      _signaling = new Signaling('ws://' + serverIP + ':4442', "Waddup")
        ..connect();

      // Customize these options to be able to control how the client reacts to the server state
      _signaling.onStateChange = (SignalingState state) {
        switch (state) {
          case SignalingState.CallStateNew:
            this.setState(() {
              _inCalling = true;
            });
            break;
          case SignalingState.CallStateBye:
            this.setState(() {
              _localRenderer.srcObject = null;
              _remoteRenderer.srcObject = null;
              _inCalling = false;
            });
            break;
          case SignalingState.CallStateInvite:
          case SignalingState.CallStateConnected:
          case SignalingState.CallStateRinging:
          case SignalingState.ConnectionClosed:
          case SignalingState.ConnectionError:
          case SignalingState.ConnectionOpen:
            break;
        }
      };

      // ?
      _signaling.onPeersUpdate = ((event) {
        this.setState(() {
          _selfId = event['self'];
          _peers = event['peers'];
        });
      });

      // On local image?
      _signaling.onLocalStream = ((stream) {
        _localRenderer.srcObject = stream;
      });

      // Most likely on remote image
      _signaling.onAddRemoteStream = ((stream) {
        _remoteRenderer.srcObject = stream;
      });

      // Disconnect from stream!
      _signaling.onRemoveRemoteStream = ((stream) {
        _remoteRenderer.srcObject = null;
      });
    }
  }

  _invitePeer(context, peerId, use_screen) async {
    if (_signaling != null && peerId != _selfId) {
      _signaling.invite(peerId, 'video', use_screen);
    }
  }

  _hangUp() {
    if (_signaling != null) {
      _signaling.bye();
    }
  }

  _switchCamera() {
    _signaling.switchCamera();
  }

  // Mute mic should probably be imlemented...
  _muteMic() {}

  // ------------
  // Widget Stuff
  // ------------

  @override
  void initState() {
    super.initState();
    initRenderers(); // Create the rendering objects!
    _connect(); // Connect to the signalling server
    WidgetsBinding.instance.addObserver(this); // Not sure what this does...
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    super.dispose();
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
  void checkPaused(int i) async {
    // What is i supposed to be?
    if (i == 5) {
      // Going away when phone powered off
      if (_lastLifecycleState == AppLifecycleState.paused ||
          _lastLifecycleState == AppLifecycleState.inactive) {
        debugPrint("Going Away");

        // Firestore stuff...
        Map<String, dynamic> bodyCha = {
          "${args[1]}": {
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
        var url = urlBase + "/set_status";
        var response = await http.post(url, body: body);

        // Recursive call
        checkPaused(i + 1);
      } else {
        print("Resuming");

        // Firebase call
        Map<String, dynamic> bodyCha = {
          "${args[1]}": {
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
        var url = urlBase + "/set_status";
        var response = await http.post(url, body: body);
        return;
      }
    }
    // When the count gets up to 150...
    else if (i == 150) {
      // When 150 'ticks' have passed, loggout if still inactive...
      if (_lastLifecycleState == AppLifecycleState.paused ||
          _lastLifecycleState == AppLifecycleState.inactive) {
        print("Logging Out");

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
          "${args[1]}": {
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
        var url = urlBase + "/set_status";
        var response = await http.post(url, body: body);
      }
      // Exit regardless?
      exit(0); // Does this cause the application to shutdown?
    } else {
      // Wait for 2 seconds
      await Future.delayed(Duration(seconds: 2));

      if (_lastLifecycleState == AppLifecycleState.paused ||
          _lastLifecycleState == AppLifecycleState.inactive) {
        checkPaused(i + 1);
      } else {
        print("Resuming");

        Map<String, dynamic> bodyCha = {
          "${args[1]}": {
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
        var url = urlBase + "/set_status";
        var response = await http.post(url, body: body);
        return;
      }
    }
  }

  // ----------------------
  // Refactored Bulid Stuff
  // ----------------------
  Widget get vipAppBar {
    if (_inCalling)
      return null;
    else
      return AppBar(title: Text(''));
  }

  Widget get callButtons {
    if (_inCalling)
      return SizedBox(
          width: 200.0,
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FloatingActionButton(
                  child: const Icon(Icons.switch_camera),
                  onPressed: _switchCamera,
                ),
                FloatingActionButton(
                  onPressed: _hangUp,
                  tooltip: 'Hangup',
                  child: new Icon(Icons.call_end),
                  backgroundColor: Colors.pink,
                ),
                FloatingActionButton(
                  child: const Icon(Icons.mic_off),
                  onPressed: _muteMic,
                )
              ]));
    else
      return null;
  }

  Widget get lookForHelpers {
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

  Widget get callForHelpButton {
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

  Widget get totalOnlineBlock {
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

  Widget get vipCountBlock {
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

  Widget get helperCountBlock {
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
  Widget get vipHome {
    return Container(
      child: Column(
        children: <Widget>[
          callForHelpButton,
          totalOnlineBlock,
          Row(
            children: <Widget>[vipCountBlock, helperCountBlock],
          ),
        ],
      ),
    );
  }

  // Build what?
  Widget get _buildSomething {
    if (_selectedIndex == 1) {
      return lookForHelpers;
    } else {
      return vipHome;
    }
  }

  Widget get vipAppBody {
    if (_inCalling)
      return OrientationBuilder(builder: (context, orientation) {
        return new Container(
          child: new Stack(children: <Widget>[
            new Positioned(
                left: 0.0,
                right: 0.0,
                top: 0.0,
                bottom: 0.0,
                child: new Container(
                  margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: new RTCVideoView(_remoteRenderer),
                  decoration: new BoxDecoration(color: Colors.black54),
                )),
            new Positioned(
              left: 20.0,
              top: 20.0,
              child: new Container(
                width: orientation == Orientation.portrait ? 90.0 : 120.0,
                height: orientation == Orientation.portrait ? 120.0 : 90.0,
                child: new RTCVideoView(_localRenderer),
                decoration: new BoxDecoration(color: Colors.black54),
              ),
            ),
          ]),
        );
      });
    else
      return _buildSomething;
  }

  Widget get vipDrawer {
    if (_inCalling)
      return null;
    else
      return Drawer(
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          children: <Widget>[
            DrawerHeader(
              child: Row(
                children: [
                  accountIcon,
                  Text(
                    args[1],
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
                    "${args[1]}": {
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

  Widget get accountIcon {
    return IconButton(
        icon: Icon(Icons.account_box),
        color: Colors.white,
        iconSize: 80,
        onPressed: () {
          //show account information?
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget get vipNavBar {
    if (_inCalling)
      return null;
    else
      return BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.visibility), title: Text('Get Help')),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), title: Text('Look For New Helpers')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.blueGrey,
        onTap: _onItemTapped,
      );
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;

    // Put this into a seperate function that'll handle states better
    if (_lastLifecycleState != null) {
      switch (_lastLifecycleState) {
        case AppLifecycleState.resumed:
          debugPrint("Resumed"); //App Resumed
          break;
        case AppLifecycleState.inactive:
          debugPrint("Inactive");
          checkPaused(0); //THIS ONE OR
          break;
        case AppLifecycleState.paused:
          debugPrint("Paused");
          checkPaused(0); //THIS ONE
          break;
        default:
          debugPrint("Don't care");
          break;
      }
    }

    // Here's the "actual" app
    return Scaffold(
      appBar: vipAppBar,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // ?
      floatingActionButton: callButtons,
      body: vipAppBody,
      drawer: vipDrawer,
      bottomNavigationBar: vipNavBar,
    );
  }
}
