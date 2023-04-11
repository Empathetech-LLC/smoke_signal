import 'screens.dart';

import 'package:empathetech_ss_api/empathetech_ss_api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/// Enumerator for communicating with [HomeScreen] build should be returned
enum HomeBuildType {
  loading,
  auth,
  app,
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<User?> _authStream;

  /// Request permission for Firebase Cloud Messager
  /// via [AppUser.messager]
  _requestFCMPermission() async {
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
    _requestFCMPermission();
  }

  late Color themeColor = Color(EzConfig.prefs[themeColorKey]);
  late Color buttonColor = Color(EzConfig.prefs[buttonColorKey]);
  late Color themeTextColor = Color(EzConfig.prefs[themeTextColorKey]);

  late double buttonSpacer = EzConfig.prefs[buttonSpacingKey];

  /// Updates current build based on the current auth [type]
  Widget _getBuild(HomeBuildType type) {
    switch (type) {
      case HomeBuildType.app:
        return SignalBoard();

      case HomeBuildType.loading:
        return LoadingScreen();

      case HomeBuildType.auth:
      default:
        return AuthScreen();
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
            return _getBuild(HomeBuildType.loading);

          // Received response
          case ConnectionState.done:
          default:
            // Check for user data, show auth build if invalid
            if (snapshot.hasError || !snapshot.hasData)
              return _getBuild(HomeBuildType.auth);

            User? currUser = snapshot.data;
            if (currUser == null) return _getBuild(HomeBuildType.auth);

            // User is found!

            // Merge them with the user DB and initialize local class
            setToken(currUser);
            AppUser.account = currUser;
            AppUser.db = FirebaseFirestore.instance;

            // Setup a message listener

            // Listeners aren't tied to screens!
            // Notifs will be received on any page hereafter
            FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
              await EzNotifications().show(
                id: 0,
                title: message.notification?.title,
                body: message.notification?.body,
              );
            });

            // Load Smoke Signal!

            return _getBuild(HomeBuildType.app);
        }
      },
    );
  }
}
