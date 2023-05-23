import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class VideoCallPage extends StatefulWidget {


  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  static final _users = <int>[];

  final _infoStrings = <String>[];

  bool _joined = false;
  int? _remoteUid = 1;

  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initializeAgora();
  }


  Future<void> initializeAgora() async {

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: "98416c05099949e98b22e08e6a457afa",
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.joinChannel( token: '007eJxTYHjPcsR2p4LBHct5GgZ/25b7TA2oDnX4Gll07+tPhzfVUrcUGCwtTAzNkg1MDSwtLU0sUy0tkoyMUg0sUs0STUzNE9MSJSOyUxoCGRkafA4wMEIhiM/BUJacmJOTmZfOwAAA29cg8A==', channelId: 'vcalling', uid: 0, options: ChannelMediaOptions());
  }



  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.disableVideo();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agora Video Call'),
      ),
      body:

      Center(
        child: _remoteVideo(),
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: "vcalling"),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
