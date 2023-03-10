import '../user/user-api.dart';
import '../utils/constants.dart';
import '../utils/notifications.dart';
import '../utils/scaffolds.dart';
import '../utils/storage.dart';
import '../utils/custom-widgets.dart';
import '../signals/signal-board.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  late Color themeColor = Color(AppUser.prefs[themeColorKey]);
  late Color buttonColor = Color(AppUser.prefs[buttonColorKey]);
  late Color themeTextColor = Color(AppUser.prefs[themeTextColorKey]);

  late double buttonSpacer = AppUser.prefs[buttonSpacingKey];

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
            ? loadingMessage(context)
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
                      Text('Login'),
                    ),
                    Container(height: buttonSpacer),

                    // Sign up
                    ezIconButton(
                      () => Navigator.of(context).pushNamed(signupRoute),
                      () {},
                      Icon(Icons.email),
                      Text('Sign up'),
                    ),
                  ],
                ),
              ),

        // Background image/decoration
        buildDecoration(AppUser.prefs[backImageKey]),

        // Fallback background color
        Color(AppUser.prefs[appBackgroundColorKey]),

        // Drawer aka settings hamburger
        settingsDrawer(context),
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
