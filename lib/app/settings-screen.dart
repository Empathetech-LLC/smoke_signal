import '../app/app-settings.dart';
import '../signals/signal-settings.dart';
import '../utils/scaffolds.dart';
import '../utils/constants.dart';
import '../user/user-api.dart';

import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the starting index (app settings or signal settings) from the navigator args
    final args =
        (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

    return Settings(startIndex: args[indexArg]);
  }
}

class Settings extends StatefulWidget {
  const Settings({
    Key? key,
    required this.startIndex,
  }) : super(key: key);

  final int startIndex;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  //// Initialize state

  late int navIndex = widget.startIndex;

  late List<Widget> windows = [
    AppSettings(),
    SignalSettings(),
  ];

  // Gather theme data
  late Color themeColor = Color(AppUser.prefs[themeColorKey]);
  late Color themeTextColor = Color(AppUser.prefs[themeTextColorKey]);

  late Color buttonColor = Color(AppUser.prefs[buttonColorKey]);

  //// Draw state

  @override
  Widget build(BuildContext context) {
    return navScaffold(
      context,

      // Title
      'Settings',

      // Body
      IndexedStack(
        index: navIndex,
        children: windows,
      ),

      // Drawer aka settings hamburger
      null,

      // Bottom nav bar
      BottomNavigationBar(
        currentIndex: navIndex,
        onTap: (index) => setState(() {
          navIndex = index;
        }),
        backgroundColor: themeColor,
        selectedItemColor: buttonColor,
        selectedIconTheme: IconThemeData(color: buttonColor),
        unselectedItemColor: themeTextColor,
        unselectedIconTheme: IconThemeData(color: themeTextColor),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'App',
            tooltip: 'Show app settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fireplace),
            label: 'Signals',
            tooltip: 'Show signals settings',
          ),
        ],
      ),
    );
  }
}
