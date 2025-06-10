import 'package:flutter/material.dart';
import 'main.dart' show MyAppState, startOutgoingCall;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final parentState = context.findAncestorStateOfType<MyAppState>();

    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            parentState?.startOutgoingCallToEmail("star@gmail,com");
          },
          child: const Text("Start Outgoing Call"),
        ),
      ),
    );
  }
}

















