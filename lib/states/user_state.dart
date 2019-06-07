import 'package:flutter_webrtc/webrtc.dart';
import 'package:vip_flutter/user_class.dart';
import 'package:vip_flutter/webrtc_components/signaling.dart';

class UserState {
  static const String WebRTCServer = '129.113.228.50';
  User currentUser;
  bool inCalling;
  Signaling signaling;
  var selfId;
  List<dynamic> peers;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer(); //Use Webrtc
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer(); //Use Webrtc

  UserState({this.currentUser, this.inCalling, this.signaling});

  factory UserState.initialize(User user) {
    return UserState(currentUser: user, inCalling: false);
  }

  @override
  String toString() {
    return 'UserState(currentUser: $currentUser, inCalling: $inCalling, signaling: $signaling)';
  }
}
