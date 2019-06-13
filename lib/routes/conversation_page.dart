import 'package:flutter/material.dart';

import 'package:flutter_webrtc/webrtc.dart';

import 'package:vip_flutter/states/user_state_container.dart';

class ConversationPage extends StatefulWidget {
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  Widget get callButtons {
    return SizedBox(
        width: 200.0,
        child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                child: const Icon(Icons.switch_camera),
                onPressed: UserContainer.of(context).switchCamera,
              ),
              FloatingActionButton(
                onPressed: UserContainer.of(context).hangUp,
                tooltip: 'Hangup',
                child: new Icon(Icons.call_end),
                backgroundColor: Colors.pink,
              ),
              FloatingActionButton(
                child: const Icon(Icons.mic_off),
                onPressed: UserContainer.of(context).muteMic,
              )
            ]));
  }

  Widget get callBody {
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
                child: new RTCVideoView(
                    UserContainer.of(context).state.remoteRenderer),
                decoration: new BoxDecoration(color: Colors.black54),
              )),
          new Positioned(
            left: 20.0,
            top: 20.0,
            child: new Container(
              width: orientation == Orientation.portrait ? 90.0 : 120.0,
              height: orientation == Orientation.portrait ? 120.0 : 90.0,
              child: new RTCVideoView(
                  UserContainer.of(context).state.localRenderer),
              decoration: new BoxDecoration(color: Colors.black54),
            ),
          ),
        ]),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      floatingActionButton: callButtons,
      body: callBody,
    );
  }
}
