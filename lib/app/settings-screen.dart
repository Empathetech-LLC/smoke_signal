import 'color-setting-screen.dart';
import 'image-setting-screen.dart';
import 'style-setting-screen.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';

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
          warningCard(
            context: context,
            warning: 'Changes won\'t take effect until restart',
          ),
          Container(height: buttonSpacer),

          // Colors
          EZButton(
            action: () => pushScreen(context: context, screen: ColorSettingScreen()),
            body: Text('Colors'),
          ),
          Container(height: buttonSpacer),

          // Images
          EZButton(
            action: () => pushScreen(context: context, screen: ImageSettingScreen()),
            body: Text('Images'),
          ),
          Container(height: buttonSpacer),

          // Styling
          EZButton(
            action: () => pushScreen(context: context, screen: StyleSettingScreen()),
            body: Text('Styling'),
          ),
          Container(height: buttonSpacer),

          // Reset all signal settings
          GestureDetector(
            onTap: () {
              ezDialog(
                context: context,
                title: 'Reset all app settings?',
                content: ezYesNo(
                  context: context,
                  onConfirm: () {
                    AppConfig.prefs.forEach((key, value) {
                      AppConfig.preferences.remove(key);
                    });

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
        centered: true,
      ),
    );
  }
}
