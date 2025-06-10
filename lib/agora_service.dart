import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraService {
  static const String appId = "a38dd8b52c8f4466b877757d34a5b649"; // Replace with your Agora App ID
  static const String token = ""; // Provide token if required
  static const String channelName = "test_channel";

  static late RtcEngine _engine;

  static Future<void> initializeAgora() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(appId: appId),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          print('joinChannelSuccess ${connection.channelId}');
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          print('userJoined $remoteUid');
        },
        onUserOffline: (connection, remoteUid, reason) {
          print('userOffline $remoteUid');
        },
      ),
    );
  }

  static Future<void> joinChannel(String channelId) async {
    await _engine.joinChannel(
      token: token,
      channelId: channelId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  static Future<void> leaveChannel() async {
    await _engine.leaveChannel();
  }

  static Future<void> destroy() async {
    await _engine.release();
  }

  static RtcEngine get engine => _engine;
}
