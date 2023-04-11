import 'screens.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettingsScreen> {
  Color themeColor = Color(EzConfig.prefs[themeColorKey]);
  Color themeTextColor = Color(EzConfig.prefs[themeTextColorKey]);
  Color buttonColor = Color(EzConfig.prefs[buttonColorKey]);

  @override
  Widget build(BuildContext context) {
    double buttonSpacer = EzConfig.prefs[buttonSpacingKey];
    double dialogSpacer = EzConfig.prefs[dialogSpacingKey];

    return EzScaffold(
      title: Text('Settings', style: getTextStyle(titleStyleKey)),
      backgroundImage: buildDecoration(EzConfig.prefs[backImageKey]),
      backgroundColor: Color(EzConfig.prefs[backColorKey]),
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
                content: [
                  ezYesNo(
                    context,
                    onConfirm: () {
                      EzConfig.prefs.forEach((key, value) {
                        // Note we iterate rather than .clear()
                        // As [EzConfig.preferences] might contain custom [File] paths
                        EzConfig.preferences.remove(key);
                      });

                      popScreen(context, pass: true);
                      popScreen(context, pass: true);
                    },
                    onDeny: () => popScreen(context),
                    axis: Axis.vertical,
                    spacer: dialogSpacer,
                  ),
                ],
                needsClose: false,
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
