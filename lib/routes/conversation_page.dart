import 'package:flutter/material.dart';

import 'package:flutter_webrtc/webrtc.dart';
import 'package:gplayer/gplayer.dart';
import 'package:vip_flutter/states/user_state_container.dart';

class ConversationPage extends StatefulWidget {
  final bool isHelper;
  ConversationPage({this.isHelper});
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  GPlayer player;
  @override
  void initState() {
    super.initState();
    debugPrint(widget.isHelper.toString());
    if (!widget.isHelper){
      player = GPlayer(uri: 'rtmp://72.183.4.67:1935/live')
      ..init()
      ..addListener((_) {
        setState(() {
          //player.start();
        });
      });
      setState((){
        player.start();
      });
    }
  }
  @override
  void dispose() {
    if (!widget.isHelper){
      setState(() {
        player.pause();
      });
      player = null;
    }
    super.dispose();
    
  }
  Widget get callButtons {
    return SizedBox(
        width: 200.0,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                child: const Icon(Icons.switch_camera),
                onPressed: UserContainer.of(context).switchCamera,
              ),
              FloatingActionButton(
                onPressed: UserContainer.of(context).hangUp,
                tooltip: 'Hangup',
                child: Icon(Icons.call_end),
                backgroundColor: Colors.pink,
              ),
              FloatingActionButton(
                child: const Icon(Icons.mic_off),
                onPressed: UserContainer.of(context).muteMic,
              ),
            ]));
  }

  Widget get callBody {
    return OrientationBuilder(builder: (context, orientation) {
      return  Container(
        child:  Stack(children: <Widget>[
          widget.isHelper ? Positioned(
              left: 0.0,
              right: 0.0,
              top: 0.0,
              bottom: 0.0,
              child:  Container(
                margin:  EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child:  RTCVideoView(
                    UserContainer.of(context).state.remoteRenderer),
                decoration:  BoxDecoration(color: Colors.black54),
              )) : Container(),
          // widget.isHelper ? Container() : Positioned(
          //   left: 20.0,
          //   top: 20.0,
          //   child:  Container(
          //     width: orientation == Orientation.portrait ? 90.0 : 120.0,
          //     height: orientation == Orientation.portrait ? 120.0 : 90.0,
          //     child:  RTCVideoView(
          //         UserContainer.of(context).state.localRenderer),
          //     decoration:  BoxDecoration(color: Colors.black54),
          //   ),
          // ),
          widget.isHelper ? Container() : player.display ,
        ]),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: callButtons,
      body: callBody,
    );
  }
}
