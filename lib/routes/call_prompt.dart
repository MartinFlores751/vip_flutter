import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:vip_flutter/states/user_state_container.dart';

class IncomingCall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: new Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration:
                new BoxDecoration(color: Colors.grey.shade200.withOpacity(0.5)),
            child: new Center(
              child: new Text('Incoming Call', style: TextStyle(fontSize: 50)),
            ),
          ),
        ),
        Align(
          alignment: FractionalOffset.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () {
                  debugPrint("Acccepting call!");
                  UserContainer.of(context).acceptCall();
                },
                tooltip: 'Accept',
                child: new Icon(Icons.phone),
                backgroundColor: Colors.green,
              ),
              FloatingActionButton(
                onPressed: () {
                  debugPrint("Ending call...");
                  UserContainer.of(context).rejectCall();
                },
                tooltip: 'Cancel',
                child: new Icon(Icons.call_end),
                backgroundColor: Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OutgoingCall extends StatelessWidget {
  final VoidCallback frost;
  const OutgoingCall({Key key, this.frost}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: new Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration:
                new BoxDecoration(color: Colors.grey.shade200.withOpacity(0.5)),
            child: new Center(
              child: new Text('Connecting...', style: TextStyle(fontSize: 50)),
            ),
          ),
        ),
        Align(
          alignment: FractionalOffset(.5, .9), 
          child: FloatingActionButton(
            onPressed: (){
              debugPrint("Canceling call...");
              UserContainer.of(context).rejectCall();
              frost();  //removes frost effect
            },
            tooltip: 'Cancel',
            child: new Icon(Icons.call_end),
            backgroundColor: Colors.red,
          ),
        )
      ],
    );
  }
}
