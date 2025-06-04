import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import '../services/token_service.dart';

class MeetingScreen extends StatefulWidget {
  final String userName;
  final String roomCode;

  MeetingScreen({required this.userName, required this.roomCode});

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen>
    implements HMSUpdateListener, HMSActionResultListener {

  HMSSDK? _hmsSDK;
  List<HMSPeer> _peers = [];
  HMSPeer? _localPeer;
  bool _isVideoOn = true;
  bool _isAudioOn = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    _hmsSDK = HMSSDK();
    await _hmsSDK!.build();
    _hmsSDK!.addUpdateListener(listener: this);
    await _joinRoom();
  }

  Future<void> _joinRoom() async {
    try {
      // Generate token directly in the app
      String authToken = TokenService.generateToken(
        roomCode: widget.roomCode,
        userId: widget.userName,
        role: 'guest', // or 'host' based on your requirement
      );

      HMSConfig config = HMSConfig(
        authToken: authToken,
        userName: widget.userName,
      );

      await _hmsSDK!.join(config: config);
    } catch (e) {
      print("Error joining room: $e");
      _showError("Failed to join room: $e");
    }
  }

  void _toggleVideo() {
    _hmsSDK!.switchVideo(isOn: !_isVideoOn);
    setState(() {
      _isVideoOn = !_isVideoOn;
    });
  }

  void _toggleAudio() {
    _hmsSDK!.switchAudio(isOn: !_isAudioOn);
    setState(() {
      _isAudioOn = !_isAudioOn;
    });
  }

  void _leaveMeeting() {
    _hmsSDK!.leave();
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Meeting - ${widget.roomCode}'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.call_end, color: Colors.red),
            onPressed: _leaveMeeting,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: _peers.isEmpty
                ? Center(
              child: Text(
                'Waiting for others to join...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
                : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _peers.length == 1 ? 1 : 2,
                childAspectRatio: 16 / 9,
              ),
              itemCount: _peers.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _peers[index].videoTrack != null
                            ? HMSVideoView(
                          track: _peers[index].videoTrack!,
                        )
                            : Center(
                          child: CircleAvatar(
                            radius: 30,
                            child: Text(
                              _peers[index].name[0].toUpperCase(),
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _peers[index].name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: _toggleAudio,
                  backgroundColor: _isAudioOn ? Colors.blue : Colors.red,
                  child: Icon(_isAudioOn ? Icons.mic : Icons.mic_off),
                ),
                FloatingActionButton(
                  onPressed: _toggleVideo,
                  backgroundColor: _isVideoOn ? Colors.blue : Colors.red,
                  child: Icon(_isVideoOn ? Icons.videocam : Icons.videocam_off),
                ),
                FloatingActionButton(
                  onPressed: _leaveMeeting,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.call_end),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HMS Update Listener Methods
  @override
  void onJoin({required HMSRoom room}) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (peer.isLocal) {
      _localPeer = peer;
    }

    if (update == HMSPeerUpdate.peerJoined) {
      setState(() {
        _peers.add(peer);
      });
    } else if (update == HMSPeerUpdate.peerLeft) {
      setState(() {
        _peers.removeWhere((p) => p.peerId == peer.peerId);
      });
    }
  }

  @override
  void onTrackUpdate({required HMSTrack track, required HMSTrackUpdate trackUpdate, required HMSPeer peer}) {
    setState(() {});
  }

  @override
  void onHMSError({required HMSException error}) {
    _showError("HMS Error: ${error.message}");
  }

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onReconnecting() {}

  @override
  void onReconnected() {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onAudioDeviceChanged({HMSAudioDevice? currentAudioDevice, List<HMSAudioDevice>? availableAudioDevice}) {}

  @override
  void onChangeTrackStateRequest({required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onRemovedFromRoom({required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}

  @override
  void onSuccess({required HMSActionResultListenerMethod methodType, Map<String, dynamic>? arguments}) {}

  @override
  void onException({required HMSActionResultListenerMethod methodType, Map<String, dynamic>? arguments, required HMSException hmsException}) {
    _showError("Action failed: ${hmsException.message}");
  }

  @override
  void dispose() {
    _hmsSDK?.leave();
    _hmsSDK?.destroy();
    super.dispose();
  }

  @override
  void onPeerListUpdate({required List<HMSPeer> addedPeers, required List<HMSPeer> removedPeers}) {
    // TODO: implement onPeerListUpdate
  }

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {
    // TODO: implement onSessionStoreAvailable
  }
}