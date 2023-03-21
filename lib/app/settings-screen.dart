import '../app/app-settings.dart';
import '../utils/constants.dart';
import '../signals/signal-settings.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
  // Initialize state

  late int navIndex = widget.startIndex;

  late List<Widget> windows = [
    AppSettings(),
    SignalSettings(),
  ];

  // Gather theme data
  late Color themeColor = Color(AppConfig.prefs[themeColorKey]);
  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);

  late Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);

  // Draw state

  @override
  Widget build(BuildContext context) {
    return ezNavScaffold(
      context: context,
      title: 'Settings',
      body: IndexedStack(
        index: navIndex,
        children: windows,
      ),
      index: navIndex,
      onChanged: (index) => setState(() {
        navIndex = index;
      }),
      items: [
        BottomNavigationBarItem(
          icon: Icon(PlatformIcons(context).person),
          label: 'App',
          tooltip: 'Show app settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fireplace),
          label: 'Signals',
          tooltip: 'Show signals settings',
        ),
      ],
      scaffoldConfig: MaterialScaffoldData(),
    );
  }
}
