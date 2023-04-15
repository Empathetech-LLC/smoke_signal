import '../utils/utils.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';

class ColorSettingsScreen extends StatefulWidget {
  const ColorSettingsScreen({Key? key}) : super(key: key);

  @override
  _ColorSettingsState createState() => _ColorSettingsState();
}

class _ColorSettingsState extends State<ColorSettingsScreen> {
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
          title: EzText.simple('Color settings',
              style: buildTextStyle(styleKey: titleStyleKey))),

      // Body
      body: standardView(
        context: context,
        background: BoxDecoration(
          image: DecorationImage(image: EzImage.getProvider(backImageKey)),
        ),
        body: EzScrollView(
          children: [
            // User hint: hold the buttons to reset the color
            Container(height: buttonSpacer),
            EzText.simple(
              'Hold buttons to reset',
              style: buildTextStyle(styleKey: dialogContentStyleKey),
            ),
            Container(height: buttonSpacer),

            // Background
            EzColorSetting(
              toControl: backColorKey,
              message: 'Background',
            ),
            Container(height: buttonSpacer),

            // Theme
            EzColorSetting(
              toControl: themeColorKey,
              message: 'Theme',
            ),
            Container(height: buttonSpacer),

            EzColorSetting(
              toControl: themeTextColorKey,
              message: 'Theme\ntext',
              textBackgroundKey: themeColorKey,
            ),
            Container(height: buttonSpacer),

            // Buttons
            EzColorSetting(
              toControl: buttonColorKey,
              message: 'Buttons',
            ),
            Container(height: buttonSpacer),

            EzColorSetting(
              toControl: buttonTextColorKey,
              message: 'Button\ntext',
              textBackgroundKey: buttonColorKey,
            ),
            Container(height: buttonSpacer),

            // Signals
            EzColorSetting(
              toControl: watchingColorKey,
              message: 'Watching\nsignal',
            ),
            Container(height: buttonSpacer),

            EzColorSetting(
              toControl: watchingTextColorKey,
              message: 'Watching\nsignal text',
              textBackgroundKey: watchingColorKey,
            ),
            Container(height: buttonSpacer),

            EzColorSetting(
              toControl: joinedColorKey,
              message: 'Joined\nsignal',
            ),
            Container(height: buttonSpacer),

            EzColorSetting(
              toControl: joinedTextColorKey,
              message: 'Joined\nsignal text',
              textBackgroundKey: joinedColorKey,
            ),
            Container(height: buttonSpacer),

            // Reset all color settings
            GestureDetector(
              onTap: () => openDialog(
                context: context,
                dialog: EzDialog(
                  title: EzText.simple(
                    'Reset all colors?',
                    style: buildTextStyle(styleKey: dialogTitleStyleKey),
                  ),
                  contents: [
                    ezYesNo(
                      context: context,
                      onConfirm: () {
                        // Remove all color settings
                        EzConfig.preferences.remove(backColorKey);
                        EzConfig.preferences.remove(themeColorKey);
                        EzConfig.preferences.remove(themeTextColorKey);
                        EzConfig.preferences.remove(buttonColorKey);
                        EzConfig.preferences.remove(buttonTextColorKey);
                        EzConfig.preferences.remove(watchingColorKey);
                        EzConfig.preferences.remove(watchingTextColorKey);
                        EzConfig.preferences.remove(joinedColorKey);
                        EzConfig.preferences.remove(joinedTextColorKey);

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
                style: buildTextStyle(styleKey: subTitleStyleKey),
              ),
            ),
            Container(height: buttonSpacer),
          ],
        ),
      ),
    );
  }
}
