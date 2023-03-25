import '../app/app-settings.dart';
import '../signals/signal-settings.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    Key? key,
    required this.startIndex,
  }) : super(key: key);

  final int startIndex;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  late int navIndex = widget.startIndex;

  List<Widget> windows = [
    AppSettings(),
    SignalSettings(),
  ];

  Color themeColor = Color(AppConfig.prefs[themeColorKey]);
  Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);
  Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);

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
          icon: ezIcon(PlatformIcons(context).person),
          label: 'App',
          tooltip: 'Show app settings',
        ),
        BottomNavigationBarItem(
          icon: ezIcon(Icons.fireplace),
          label: 'Signals',
          tooltip: 'Show signals settings',
        ),
      ],
    );
  }
}
