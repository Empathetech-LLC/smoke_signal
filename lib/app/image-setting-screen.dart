import '../utils/constants.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';

class ImageSettingScreen extends StatefulWidget {
  const ImageSettingScreen({Key? key}) : super(key: key);

  @override
  _ImageSettingScreenState createState() => _ImageSettingScreenState();
}

class _ImageSettingScreenState extends State<ImageSettingScreen> {
  Color themeColor = Color(AppConfig.prefs[themeColorKey]);
  Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);
  Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);

  @override
  Widget build(BuildContext context) {
    double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

    return ezScaffold(
      context: context,
      title: 'Image settings',
      backgroundColor: Color(AppConfig.prefs[themeColorKey]),
      body: ezScrollView(
        children: [
          // Background
          ImageSetting(
            prefsKey: backImageKey,
            fullscreen: true,
            title: 'Image',
            credits: credits[AppConfig.prefs[backImageKey]] ?? 'Wherever you got it!',
          ),
          Container(height: buttonSpacer),

          // Signal
          ImageSetting(
            prefsKey: signalImageKey,
            fullscreen: false,
            title: 'Image',
            credits: credits[AppConfig.prefs[signalImageKey]] ?? 'Wherever you got it!',
          )
        ],
      ),
    );
  }
}
