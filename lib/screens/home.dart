import 'login.dart';
import 'sign-up.dart';
import 'signal-board.dart';
import '../utils/drawers.dart';
import '../utils/constants.dart';

import 'package:empathetech_ss_api/empathetech_ss_api.dart';
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

/// Enumerator for communitcating with [HomeScreen] build schold be returned
enum HomeBuildType {
  loading,
  auth,
  app,
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<User?> _authStream;

  /// Request permission for Firebase Cloud Messager
  /// via [AppUser.messager]
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

  late Color themeColor = Color(AppConfig.prefs[themeColorKey]);
  late Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);
  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);

  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

  /// Updates current build based on the current auth [type]
  Widget getBuild(HomeBuildType type) {
    switch (type) {
      case HomeBuildType.app:
        return SignalBoard();

      case HomeBuildType.loading:
      case HomeBuildType.auth:
      default:
        return EZScaffold(
          // Title && theme
          title: appTitle,
          backgroundImage: buildDecoration(AppConfig.prefs[backImageKey]),
          backgroundColor: Color(AppConfig.prefs[backColorKey]),

          // Body
          body: (type == HomeBuildType.loading)
              ? loadingMessage(
                  context,
                  image: buildImage(path: smokeSignalPath),
                )
              : // Show authBuild
              ezScrollView(children: [
                  // Login
                  EZButton.icon(
                    action: () => pushScreen(
                      context,
                      screen: LoginScreen(),
                    ),
                    message: 'Login',
                    icon: ezIcon(PlatformIcons(context).mail),
                  ),
                  Container(height: buttonSpacer),

                  // Sign up
                  EZButton.icon(
                    action: () => pushScreen(
                      context,
                      screen: SignUpScreen(),
                    ),
                    message: 'Sign up',
                    icon: ezIcon(PlatformIcons(context).mail),
                  ),
                ], centered: true),

          // User interaction
          drawerHeader: standardDrawerHeader(),
          drawerBody: standardDrawerBody(context),
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
            return getBuild(HomeBuildType.loading);

          // Received response
          case ConnectionState.done:
          default:
            // Check for user data, show auth build if invalid
            if (snapshot.hasError || !snapshot.hasData)
              return getBuild(HomeBuildType.auth);

            User? currUser = snapshot.data;
            if (currUser == null) return getBuild(HomeBuildType.auth);

            // User is found!

            // Merge them with the user DB and initialize local class
            setToken(currUser);
            AppUser.account = currUser;
            AppUser.db = FirebaseFirestore.instance;

            // Setup a message listener

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

            // Load Smoke Signal!

            return getBuild(HomeBuildType.app);
        }
      },
    );
  }
}
