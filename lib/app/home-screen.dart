import '../user/user-api.dart';
import '../utils/constants.dart';
import '../utils/scaffolds.dart';
import '../utils/helpers.dart';
import '../signals/signal-board.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //// Initialize state

  late Stream<User?> _authStream;

  // Request permission for firebase cloud messager
  requestFCMPermission() async {
    await AppUser.messager.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
  }

  @override
  void initState() {
    super.initState();
    _authStream = AppUser.auth.authStateChanges();
    requestFCMPermission();
  }

  // Local aliases
  final String loadingBuild = 'loadingBuild';
  final String authBuild = 'authBuild';
  final String appBuild = 'appBuild';

  // Gather theme data
  late Color themeColor = Color(AppConfig.prefs[themeColorKey]);
  late Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);
  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);

  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

  //// Draw state

  // Returns the current build based on the auth state
  Widget getBuild(String type) {
    if (type == appBuild) {
      return SignalBoard();
    } else {
      return standardScaffold(
        context,

        // Title
        appTitle,

        // Body
        (type == loadingBuild)
            ? loadingMessage(
                context, buildImage(smokeSignalPath, isAssetImage(smokeSignalPath)))
            : // Show authBuild
            Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Login
                    ezIconButton(
                      () => Navigator.of(context).pushNamed(loginRoute),
                      () {},
                      Icon(Icons.email),
                      Icon(Icons.email),
                      PlatformText('Login'),
                    ),
                    Container(height: buttonSpacer),

                    // Sign up
                    ezIconButton(
                      () => Navigator.of(context).pushNamed(signupRoute),
                      () {},
                      Icon(Icons.email),
                      Icon(Icons.email),
                      PlatformText('Sign up'),
                    ),
                  ],
                ),
              ),

        // Background image/decoration
        buildDecoration(AppConfig.prefs[backImageKey]),

        // Fallback background color
        Color(AppConfig.prefs[backColorKey]),

        // Android drawer aka settings hamburger
        settingsDrawer(context),

        // iOS nav (top) bar
        CupertinoNavigationBar(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authStream,
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        switch (snapshot.connectionState) {
          // Waiting on response
          case ConnectionState.waiting:
            return getBuild(loadingBuild);

          // Received response
          case ConnectionState.done:
          default:
            // Check for user data, show auth build if invalid
            if (snapshot.hasError || !snapshot.hasData) return getBuild(authBuild);

            User? currUser = snapshot.data;
            if (currUser == null) return getBuild(authBuild);

            //// User is found!

            // Merge them with the user DB and initialize local class
            setToken(currUser);
            AppUser.account = currUser;
            AppUser.db = FirebaseFirestore.instance;

            //// Setup a message listener

            // Listeners aren't tied to screens!
            // Notifs will be received on any page hereafter
            FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
              await NotificationService().show(
                0,
                message.notification?.title,
                message.notification?.body,
                null,
              );
            });

            //// Load Smoke Signal!

            return getBuild(appBuild);
        }
      },
    );
  }
}
