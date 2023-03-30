import '../utils/constants.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';

class ColorSettingScreen extends StatefulWidget {
  const ColorSettingScreen({Key? key}) : super(key: key);

  @override
  _ColorSettingScreenState createState() => _ColorSettingScreenState();
}

class _ColorSettingScreenState extends State<ColorSettingScreen> {
  Color themeColor = Color(AppConfig.prefs[themeColorKey]);
  Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);
  Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);

  @override
  Widget build(BuildContext context) {
    double buttonSpacer = AppConfig.prefs[buttonSpacingKey];
    double dialogSpacer = AppConfig.prefs[dialogSpacingKey];

    return ezScaffold(
      context: context,
      title: 'Settings',
      backgroundColor: Color(AppConfig.prefs[themeColorKey]),
      body: ezScrollView(
        children: [
          // User hint: hold the buttons to reset the color
          ezText(
            'Hold buttons to reset',
            style: getTextStyle(dialogContentStyleKey),
          ),
          Container(height: dialogSpacer),

          // Background
          ColorSetting(toControl: backColorKey, message: 'Background color'),
          Container(height: buttonSpacer),

          // Theme
          ColorSetting(toControl: themeColorKey, message: 'Theme'),
          Container(height: buttonSpacer),
          ColorSetting(toControl: themeTextColorKey, message: 'Theme text'),
          Container(height: buttonSpacer),

          // Buttons
          ColorSetting(toControl: buttonColorKey, message: 'Buttons'),
          Container(height: buttonSpacer),
          ColorSetting(toControl: buttonTextColorKey, message: 'Button text'),
          Container(height: buttonSpacer),

          // Signals
          ColorSetting(toControl: watchingColorKey, message: 'Watching'),
          Container(height: buttonSpacer),
          ColorSetting(toControl: watchingTextColorKey, message: 'Watching text'),
          Container(height: buttonSpacer),

          ColorSetting(toControl: joinedColorKey, message: 'Joined'),
          Container(height: buttonSpacer),
          ColorSetting(toControl: joinedTextColorKey, message: 'Joined text'),
          Container(height: buttonSpacer),

          // Reset all color settings
          GestureDetector(
            onTap: () {
              ezDialog(
                context: context,
                title: 'Reset all colors?',
                content: ezYesNo(
                  context: context,
                  onConfirm: () {
                    // Remove all color settings
                    AppConfig.preferences.remove(backColorKey);
                    AppConfig.preferences.remove(themeColorKey);
                    AppConfig.preferences.remove(themeTextColorKey);
                    AppConfig.preferences.remove(buttonColorKey);
                    AppConfig.preferences.remove(buttonTextColorKey);
                    AppConfig.preferences.remove(watchingColorKey);
                    AppConfig.preferences.remove(watchingTextColorKey);
                    AppConfig.preferences.remove(joinedColorKey);
                    AppConfig.preferences.remove(joinedTextColorKey);

                    popScreen(context);
                  },
                  onDeny: () => popScreen(context),
                  axis: Axis.vertical,
                  spacer: dialogSpacer,
                ),
              );
            },
            child: ezText(
              'Reset all',
              style: getTextStyle(subTitleStyleKey),
            ),
          ),
        ],
      ),
    );
  }
}
