import '../utils/constants.dart';
import '../app/home-screen.dart';
import '../user/user-api.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handle notifations while the app is in the background/closed
Future<void> _backgroundMsgHandler(RemoteMessage message) async {
  doNothing();
}

void main() async {
  // Required first method on async main
  WidgetsFlutterBinding.ensureInitialized();

  // Lock app to portait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize app config
  AppConfig.focus = FocusManager.instance;
  AppConfig.preferences = await SharedPreferences.getInstance();
  AppConfig.init(assetPaths: assets, customDefaults: customDefaults);

  // Setup notification service
  await NotificationService().init();

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

/// Smoke Signal app definition
/// Jolly co-operation!
class SmokeSignal extends StatelessWidget {
  const SmokeSignal({super.key});

  @override
  Widget build(BuildContext context) {
    return ezApp(
      appTitle: appTitle,
      routes: {homeRoute: (context) => HomeScreen()},
    );
  }
}
