import '../user/profile-settings-screen.dart';
import '../user/login-screen.dart';
import '../user/reset-password-screen.dart';
import '../user/sign-up-screen.dart';
import '../utils/constants.dart';
import '../signals/signal-members-screen.dart';
import '../signals/create-signal-screen.dart';
import '../app/home-screen.dart';
import '../app/settings-screen.dart';
import '../user/user-api.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

// Required function
// Handles notifations while the app is in the background/closed
Future<void> _backgroundMsgHandler(RemoteMessage message) async {
  // Smoke Signal notifications don't have actions (currently)
}

void main() async {
  // Required first method on asynchronous main
  WidgetsFlutterBinding.ensureInitialized();

  // Lock app to portait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize app config
  AppConfig.focus = FocusManager.instance;
  AppConfig.preferences = await SharedPreferences.getInstance();
  AppConfig.init(customDefaults);

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

class SmokeSignal extends StatelessWidget {
  const SmokeSignal({super.key});

  @override
  Widget build(BuildContext context) {
    // Define app theme and routes (pages/screens/etc)
    return PlatformApp(
      // Theme data
      debugShowCheckedModeBanner: false,
      title: appTitle,

      // Android app data
      material: (context, platform) => MaterialAppData(),

      // iOS app data
      cupertino: (context, platform) => CupertinoAppData(),

      // Route data
      initialRoute: homeRoute,
      routes: {
        signupRoute: (context) => SignUpScreen(),
        loginRoute: (context) => LoginScreen(),
        resetPasswordRoute: (context) => ResetScreen(),
        homeRoute: (context) => HomeScreen(),
        settingsRoute: (context) => SettingsScreen(),
        profileSettingsRoute: (context) => ProfileSettingsScreen(),
        createSignalRoute: (context) => CreateSignalScreen(),
        signalMembersRoute: (context) => SignalMemberScreen(),
      },
    );
  }
}
