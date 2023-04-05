import '../utils/constants.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';

class ImageSettingsScreen extends StatefulWidget {
  const ImageSettingsScreen({Key? key}) : super(key: key);

  @override
  _ImageSettingsState createState() => _ImageSettingsState();
}

class _ImageSettingsState extends State<ImageSettingsScreen> {
  late Color themeColor = Color(AppConfig.prefs[themeColorKey]);
  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);
  late Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);

  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

  @override
  Widget build(BuildContext context) {
    return EZScaffold(
      title: 'Image settings',
      backgroundColor: Color(AppConfig.prefs[backColorKey]),
      body: ezScrollView(
        children: [
          // Background
          ImageSetting(
            prefsKey: backImageKey,
            fullscreen: true,
            title: 'Background',
            credits: credits[AppConfig.prefs[backImageKey]] ?? 'Wherever you got it!',
          ),
          Container(height: buttonSpacer),

          // Signal
          ImageSetting(
            prefsKey: signalImageKey,
            fullscreen: false,
            title: 'Signal',
            credits: credits[AppConfig.prefs[signalImageKey]] ?? 'Wherever you got it!',
          ),
          Container(height: buttonSpacer),
        ],
        centered: true,
      ),
    );
  }
}
