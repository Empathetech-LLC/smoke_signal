import 'screens/home.dart';
import '../utils/constants.dart';

import 'package:empathetech_ss_api/empathetech_ss_api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Handle notifications while the app is in the background/closed
Future<void> _backgroundMsgHandler(RemoteMessage message) async {
  doNothing();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EzConfig.init(
    assetPaths: assets,
    customDefaults: customDefaults,
    orientations: [DeviceOrientation.portraitUp],
  );

  // Setup notification service
  EzNotifications().init();

  // Initialize firebase
  await Firebase.initializeApp();

  // Initialize app user
  AppUser.messager = FirebaseMessaging.instance;
  AppUser.auth = FirebaseAuth.instance;

  // Receive notifications
  FirebaseMessaging.onBackgroundMessage(_backgroundMsgHandler);
  await AppUser.messager.getInitialMessage();

  runApp(SmokeSignal());
}

class SmokeSignal extends StatelessWidget {
  /// Jolly co-operation!
  const SmokeSignal({super.key});

  @override
  Widget build(BuildContext context) {
    return EzApp(
      appTitle: appTitle,
      routes: {homeRoute: (context) => HomeScreen()},
    );
  }
}
