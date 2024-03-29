import '../utils/constants.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';

class ColorSettingsScreen extends StatefulWidget {
  const ColorSettingsScreen({Key? key}) : super(key: key);

  @override
  _ColorSettingsState createState() => _ColorSettingsState();
}

class _ColorSettingsState extends State<ColorSettingsScreen> {
  Color themeColor = Color(AppConfig.prefs[themeColorKey]);
  Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);
  Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);

  @override
  Widget build(BuildContext context) {
    double buttonSpacer = AppConfig.prefs[buttonSpacingKey];
    double dialogSpacer = AppConfig.prefs[dialogSpacingKey];

    return EZScaffold(
      title: 'Color settings',
      backgroundColor: Color(AppConfig.prefs[backColorKey]),
      body: ezScrollView(
        children: [
          // User hint: hold the buttons to reset the color
          Container(height: buttonSpacer),
          Text(
            'Hold buttons to reset',
            style: getTextStyle(dialogContentStyleKey),
          ),
          Container(height: buttonSpacer),

          // Background
          ColorSetting(
            toControl: backColorKey,
            message: 'Background',
          ),
          Container(height: buttonSpacer),

          // Theme
          ColorSetting(
            toControl: themeColorKey,
            message: 'Theme',
          ),
          Container(height: buttonSpacer),

          ColorSetting(
            toControl: themeTextColorKey,
            message: 'Theme\ntext',
            textBackground: AppConfig.prefs[themeColorKey],
          ),
          Container(height: buttonSpacer),

          // Buttons
          ColorSetting(
            toControl: buttonColorKey,
            message: 'Buttons',
          ),
          Container(height: buttonSpacer),

          ColorSetting(
            toControl: buttonTextColorKey,
            message: 'Button\ntext',
            textBackground: AppConfig.prefs[buttonColorKey],
          ),
          Container(height: buttonSpacer),

          // Signals
          ColorSetting(
            toControl: watchingColorKey,
            message: 'Watching\nsignal',
          ),
          Container(height: buttonSpacer),

          ColorSetting(
            toControl: watchingTextColorKey,
            message: 'Watching\nsignal text',
            textBackground: AppConfig.prefs[watchingColorKey],
          ),
          Container(height: buttonSpacer),

          ColorSetting(
            toControl: joinedColorKey,
            message: 'Joined\nsignal',
          ),
          Container(height: buttonSpacer),

          ColorSetting(
            toControl: joinedTextColorKey,
            message: 'Joined\nsignal text',
            textBackground: AppConfig.prefs[joinedColorKey],
          ),
          Container(height: buttonSpacer),

          // Reset all color settings
          GestureDetector(
            onTap: () {
              ezDialog(
                context,
                title: 'Reset all colors?',
                content: ezYesNo(
                  context,
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
          Container(height: buttonSpacer),
        ],
      ),
    );
  }
}
