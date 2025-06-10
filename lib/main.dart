import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

import 'app_router.dart';
import 'navigation_service.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Outgoing call event listener
    // FlutterCallkitIncoming.onEvent.listen(_onCallEvent);

    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event != null) {
        _onCallEvent(event);
      }
    });
  }



  Future<void> _onCallEvent(CallEvent event) async {
    print('[CallEvent] ${event.event}');
    if (event.event == Event.actionCallStart) {
      // Outgoing call started — navigate to calling page
      NavigationService.instance.pushNamedIfNotCurrent(
        AppRoute.callingPage,
        args: event.body,
      );
    }
  }

  Future<Map<String, dynamic>?> fetchUserByEmail(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  Future<void> startOutgoingCallToEmail(String email) async {
    final user = await fetchUserByEmail(email);
    if (user == null) {
      print('User not found!');
      return;
    }

    String callId = _uuid.v4();

    final params = CallKitParams(
      id: callId,
      nameCaller: user['name'] ?? 'Unknown',
      appName: 'Oscar App',
      avatar: 'https://i.pravatar.cc/100',
      handle: user['email'] ?? 'unknown@email.com',
      type: 1, // Outgoing call
      extra: <String, dynamic>{'userId': user['uid'] ?? 'unknown'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
      ),
    );

    await FlutterCallkitIncoming.startCall(params);
  }

  // Future<void> startOutgoingCall() async {
  //   String callId = _uuid.v4();
  //
  //   final params = CallKitParams(
  //     id: callId,
  //     nameCaller: 'Sapna Jha',
  //     appName: 'Oscar App',
  //     avatar: 'https://i.pravatar.cc/100',
  //     handle: '9876543210',
  //     type: 1, // ✅ Outgoing Call
  //     extra: <String, dynamic>{'userId': 'sapna123'},
  //     android: const AndroidParams(
  //       isCustomNotification: true,
  //       isShowLogo: true,
  //       ringtonePath: 'system_ringtone_default',
  //       backgroundColor: '#0955fa',
  //       actionColor: '#4CAF50',
  //       textColor: '#ffffff',
  //     ),
  //     ios: const IOSParams(
  //       iconName: 'CallKitLogo',
  //       handleType: '',
  //       supportsVideo: true,
  //       maximumCallGroups: 2,
  //       maximumCallsPerCallGroup: 1,
  //       supportsDTMF: true,
  //       supportsHolding: true,
  //       supportsGrouping: false,
  //       supportsUngrouping: false,
  //     ),
  //   );
  //
  //   await FlutterCallkitIncoming.startCall(params);
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oscar Call',
      navigatorKey: NavigationService.instance.navigationKey,
      navigatorObservers: [NavigationService.instance.routeObserver],
      onGenerateRoute: AppRoute.generateRoute,
      initialRoute: AppRoute.homePage,
    );
  }
}



