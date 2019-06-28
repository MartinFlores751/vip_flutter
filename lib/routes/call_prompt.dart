import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:vip_flutter/states/user_state_container.dart';

class IncomingCall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration:
                BoxDecoration(color: Colors.grey.shade200.withOpacity(0.5)),
            child: Column(children: <Widget>[
              Center(
                child:
                    Text('Call', style: Theme.of(context).textTheme.display3),
              ),
              GestureDetector(
                onTap: () {
                  debugPrint("Accepting call!");
                  UserContainer.of(context).acceptCall();
                },
                child: Container(
                  child: Icon(Icons.phone),
                ),
              ),
              GestureDetector(
                onTap: () {
                  debugPrint("Rejecting call...");
                  UserContainer.of(context).rejectCall();
                },
                child: Container(
                  child: Icon(Icons.call_end),
                ),
              )
            ]),
          ),
        ),
      ),
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
            decoration: new BoxDecoration(
              color: Colors.grey.shade200.withOpacity(0.5)
            ),
            child: new Center(
              child: new Text(
                'Connecting...',
                style: TextStyle(fontSize: 50)
              ),
            ),
          ),
        ),
        Align(
        alignment: FractionalOffset(.5, .9), 
        child: FloatingActionButton(
          onPressed: (){
            debugPrint("Rejecting call...");
            UserContainer.of(context).rejectCall();
            frost();
          },
          tooltip: 'Cancel',
          child: new Icon(Icons.call_end),
          backgroundColor: Colors.red,
        ),
      ),
      ],
    );
  }
}
