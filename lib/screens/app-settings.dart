import 'color-settings.dart';
import 'image-settings.dart';
import 'style-settings.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettingsScreen> {
  Color themeColor = Color(AppConfig.prefs[themeColorKey]);
  Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);
  Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);

  @override
  Widget build(BuildContext context) {
    double buttonSpacer = AppConfig.prefs[buttonSpacingKey];
    double dialogSpacer = AppConfig.prefs[dialogSpacingKey];

    return EZScaffold(
      title: 'Settings',
      backgroundImage: buildDecoration(AppConfig.prefs[backImageKey]),
      backgroundColor: Color(AppConfig.prefs[backColorKey]),
      body: ezScrollView(
        children: [
          warningCard(
            context,
            warning: 'Changes won\'t take effect until restart',
          ),
          Container(height: 2 * buttonSpacer),

          // Colors
          EZButton(
            action: () => pushScreen(context, screen: ColorSettingsScreen()),
            body: Text('Colors'),
          ),
          Container(height: buttonSpacer),

          // Images
          EZButton(
            action: () => pushScreen(context, screen: ImageSettingsScreen()),
            body: Text('Images'),
          ),
          Container(height: buttonSpacer),

          // Styling
          EZButton(
            action: () => pushScreen(context, screen: StyleSettingsScreen()),
            body: Text('Styling'),
          ),
          Container(height: 2 * buttonSpacer),

          // Reset all signal settings
          GestureDetector(
            onTap: () {
              ezDialog(
                context,
                title: 'Reset all settings?',
                content: ezYesNo(
                  context,
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
            child: Text(
              'Reset all',
              style: getTextStyle(subTitleStyleKey),
            ),
          ),
        ],
      ),
    );
  }
}
