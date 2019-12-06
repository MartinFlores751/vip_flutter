import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:vip_flutter/user_class.dart';
import 'package:vip_flutter/webrtc_components/signaling.dart';

class UserState {
  static const String WebRTCServer = 'demo.cloudwebrtc.com';
  User currentUser;
  bool inCalling;
  bool isRinging;
  Signaling signaling;
  var selfId;
  List<dynamic> peers;
  RTCVideoRenderer localRenderer; //Use Webrtc
  RTCVideoRenderer remoteRenderer; //Use Webrtc
  AudioCache audioPlayer = AudioCache();


  UserState(
      {this.currentUser,
      this.inCalling,
      this.isRinging,
      this.signaling,
      this.localRenderer,
      this.remoteRenderer});

  factory UserState.initialize(User user) {
    return UserState(
        currentUser: user,
        inCalling: false,
        isRinging: false,
        localRenderer: RTCVideoRenderer(),
        remoteRenderer: RTCVideoRenderer());
  }

  @override
  String toString() {
    return 'UserState(currentUser: $currentUser, inCalling: $inCalling, signaling: $signaling)';
  }
}
