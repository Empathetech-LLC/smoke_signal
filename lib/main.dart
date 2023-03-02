import '../user/profile-settings-screen.dart';
import '../user/login-screen.dart';
import '../user/reset-password-screen.dart';
import '../user/sign-up-screen.dart';
import '../utils/constants.dart';
import '../utils/notifications.dart';
import '../utils/text.dart';
import '../signals/signal-members-screen.dart';
import '../signals/create-signal-screen.dart';
import '../app/home-screen.dart';
import '../app/settings-screen.dart';
import '../user/user-api.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Setup notification service
  await NotificationService().init();

  // Initialize firebase
  await Firebase.initializeApp();

  // Initialize app user
  AppUser.focus = FocusManager.instance;
  AppUser.preferences = await SharedPreferences.getInstance();

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
    AppUser.init();
    // Gather theme data
    Color themeColor = Color(AppUser.prefs[themeColorKey]);
    Color themeTextColor = Color(AppUser.prefs[themeTextColorKey]);
    Color buttonColor = Color(AppUser.prefs[buttonColorKey]);
    Color buttonTextColor = Color(AppUser.prefs[buttonTextColorKey]);

    // Define the default text theme so third party widgets *should* always use our theme
    // We will overwrite the text theme wherever necessary
    TextTheme defaultTextTheme() {
      TextStyle defaultTextStyle = getTextStyle(defaultStyle);

      return TextTheme(
        labelLarge: defaultTextStyle,
        bodyLarge: defaultTextStyle,
        titleLarge: defaultTextStyle,
        displayLarge: defaultTextStyle,
        headlineLarge: defaultTextStyle,
        labelMedium: defaultTextStyle,
        bodyMedium: defaultTextStyle,
        titleMedium: defaultTextStyle,
        displayMedium: defaultTextStyle,
        headlineMedium: defaultTextStyle,
        labelSmall: defaultTextStyle,
        bodySmall: defaultTextStyle,
        titleSmall: defaultTextStyle,
        displaySmall: defaultTextStyle,
        headlineSmall: defaultTextStyle,
      );
    }

    // Configure the app theme
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,

      theme: ThemeData(
        primaryColor: themeColor,

        // App bar
        appBarTheme: AppBarTheme(
          backgroundColor: themeColor,
          centerTitle: true,
          iconTheme: IconThemeData(color: themeTextColor),
          titleTextStyle: getTextStyle(titleStyle),
        ),

        // Text/icons
        textTheme: defaultTextTheme(),
        primaryTextTheme: defaultTextTheme(),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: themeTextColor,
          selectionColor: themeColor,
          selectionHandleColor: buttonColor,
        ),
        hintColor: themeTextColor,
        iconTheme: IconThemeData(color: themeTextColor),

        // Sliders
        sliderTheme: SliderThemeData(
          thumbColor: buttonColor,
          disabledThumbColor: themeColor,
          overlayColor: buttonColor,
          activeTrackColor: buttonColor,
          activeTickMarkColor: buttonTextColor,
          inactiveTrackColor: themeColor,
          inactiveTickMarkColor: themeTextColor,
          valueIndicatorTextStyle: getTextStyle(dialogContentStyle),
          overlayShape: SliderComponentShape.noOverlay,
        ),

        // Dialogs
        dialogTheme: DialogTheme(
          backgroundColor: themeColor,
          iconColor: themeTextColor,
          alignment: Alignment.center,
          titleTextStyle: getTextStyle(dialogTitleStyle),
          contentTextStyle: getTextStyle(dialogContentStyle),
          actionsPadding: EdgeInsets.all(padding),
        ),
      ),

      // Configure the app routes aka pages aka screens
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
