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
      background: BoxDecoration(color: Color(EzConfig.prefs[backColorKey])),
      appBar: EzAppBar(
          title: EzText.simple('Settings', style: buildTextStyle(style: titleStyleKey))),

      // Body
      body: standardView(
        context: context,
        background: BoxDecoration(
          image: DecorationImage(image: EzImage.getProvider(backImageKey)),
        ),
        body: EzScrollView(
          children: [
            warningCard(
              context: context,
              warning: 'Changes won\'t take effect until restart',
            ),
            Container(height: 2 * buttonSpacer),

            // Colors
            EzButton(
              action: () => pushScreen(context: context, screen: ColorSettingsScreen()),
              body: EzText.simple('Colors'),
            ),
            Container(height: buttonSpacer),

            // Images
            EzButton(
              action: () => pushScreen(context: context, screen: ImageSettingsScreen()),
              body: EzText.simple('Images'),
            ),
            Container(height: buttonSpacer),

            // Styling
            EzButton(
              action: () => pushScreen(context: context, screen: StyleSettingsScreen()),
              body: EzText.simple('Styling'),
            ),
            Container(height: 2 * buttonSpacer),

            // Reset all signal settings
            GestureDetector(
              onTap: () => openDialog(
                context: context,
                dialog: EzDialog(
                  title: EzText.simple(
                    'Reset all settings?',
                    style: buildTextStyle(style: dialogTitleStyleKey),
                  ),
                  contents: [
                    ezYesNo(
                      context: context,
                      onConfirm: () {
                        EzConfig.prefs.forEach((key, value) {
                          // Note we iterate rather than .clear()
                          // As [EzConfig.preferences] might contain custom [File] paths
                          EzConfig.preferences.remove(key);
                        });

                        popScreen(context: context, pass: true);
                        popScreen(context: context, pass: true);
                      },
                      onDeny: () => popScreen(context: context),
                      axis: Axis.vertical,
                      spacer: dialogSpacer,
                    ),
                  ],
                  needsClose: false,
                ),
              ),
              child: EzText.simple(
                'Reset all',
                style: buildTextStyle(style: subTitleStyleKey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
