import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:vip_flutter/states/user_state.dart';
import 'package:vip_flutter/webrtc_components/signaling.dart';

class UserContainer extends StatefulWidget {
  final UserState state;
  final Widget child;

  UserContainer({this.state, @required this.child});

  static _UserContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  _UserContainerState createState() => _UserContainerState();
}

class _UserContainerState extends State<UserContainer> {
  UserState state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = UserState.initialize(ModalRoute.of(context).settings.arguments);
    }
  }

  // Create the two renderers for the VIP
  initRenderers() async {
    // Only one of these are needed!
    await state.localRenderer.initialize();
    await state.remoteRenderer.initialize();
  }

  // When the Widget gets closed
  @override
  deactivate() {
    super.deactivate();
    if (state.signaling != null) state.signaling.close();
    state.localRenderer.dispose();
    state.remoteRenderer.dispose();
  }

  void connect() async {
    // If not signalling to the server, perform setup
    if (state.signaling == null) {
      debugPrint('Connecting to signaling server...');
      state.signaling = new Signaling(
          'ws://' + UserState.WebRTCServer + ':4442',
          state.currentUser.userName)
        ..connect();

      // Customize these options to be able to control how the client reacts to the server state
      state.signaling.onStateChange = ((SignalingState currentSignal) {
        switch (currentSignal) {
          case SignalingState.CallStateNew:
            debugPrint('New call');
            this.setState(() {
              state.inCalling = true;
            });
            break;
          case SignalingState.CallStateBye:
            debugPrint('Call ended');
            this.setState(() {
              state.localRenderer.srcObject = null;
              state.remoteRenderer.srcObject = null;
              state.inCalling = false;
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
      });

      state.signaling.onPeersUpdate = ((event) {
        state.selfId = event['self'];
        state.peers = event['peers'];
      });

      // On local image?
      state.signaling.onLocalStream = ((stream) {
        state.localRenderer.srcObject = stream;
      });

      // Most likely on remote image
      state.signaling.onAddRemoteStream = ((stream) {
        state.remoteRenderer.srcObject = stream;
      });

      // Disconnect from stream!
      state.signaling.onRemoveRemoteStream = ((stream) {
        state.remoteRenderer.srcObject = null;
      });
    }
  }

  _invitePeer(context, peerId, useScreen) async {
    if (state.signaling != null && peerId != state.selfId) {
      state.signaling.invite(peerId, 'video', useScreen);
    }
  }

  callUser(String username) async {
    // TODO: Write better code for this!!!
    debugPrint(state.peers.toString());
    state.peers?.forEach((peer) {
      Map<String, dynamic> p = peer;
      if (p['name'] == username) {
        _invitePeer(context, p['id'], false);
      }
    });
  }

  hangUp() {
    if (state.signaling != null) {
      state.signaling.bye();
    }
  }

  switchCamera() {
    state.signaling.switchCamera();
  }

  // Mute mic should probably be imlemented...
  muteMic() {}

  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final _UserContainerState data;

  _InheritedStateContainer(
      {Key key, @required this.data, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer oldWidget) => true;
}
