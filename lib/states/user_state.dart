import 'package:flutter_webrtc/webrtc.dart';
import 'package:vip_flutter/user_class.dart';
import 'package:vip_flutter/webrtc_components/signaling.dart';

class UserState {
  static const String WebRTCServer = '192.168.1.127';
  User currentUser;
  bool inCalling;
  Signaling signaling;
  var selfId;
  List<dynamic> peers;
  RTCVideoRenderer localRenderer; //Use Webrtc
  RTCVideoRenderer remoteRenderer; //Use Webrtc

  UserState(
      {this.currentUser,
      this.inCalling,
      this.signaling,
      this.localRenderer,
      this.remoteRenderer});

  factory UserState.initialize(User user) {
    return UserState(
        currentUser: user,
        inCalling: false,
        localRenderer: RTCVideoRenderer(),
        remoteRenderer: RTCVideoRenderer());
  }

  @override
  String toString() {
    return 'UserState(currentUser: $currentUser, inCalling: $inCalling, signaling: $signaling)';
  }
}
