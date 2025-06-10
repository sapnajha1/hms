
import 'dart:async';
import 'package:flutter/material.dart';

import 'agora_service.dart';

class CallingPage extends StatefulWidget {
  const CallingPage({super.key});

  @override
  State<CallingPage> createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  late Timer _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // final channelId = args?['id'] ?? 'test_channel';
    //
    // _startAgora(channelId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    // Use args here safely
    print(args); // Or set to a variable
  }

  Future<void> _startAgora(String channelId) async {
    await AgoraService.initializeAgora();
    await AgoraService.joinChannel(channelId);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    _timer.cancel();
    AgoraService.leaveChannel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final callerName = args?['nameCaller'] ?? 'Unknown';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.call, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              callerName,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              _formatTime(_secondsElapsed),
              style: const TextStyle(color: Colors.white70, fontSize: 20),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Close call screen
              },
              icon: const Icon(Icons.call_end),
              label: const Text("End Call"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




