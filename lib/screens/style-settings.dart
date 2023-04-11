import '../utils/utils.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';

class StyleSettingsScreen extends StatefulWidget {
  const StyleSettingsScreen({Key? key}) : super(key: key);

  @override
  _StyleSettingsState createState() => _StyleSettingsState();
}

class _StyleSettingsState extends State<StyleSettingsScreen> {
  Color themeColor = Color(EzConfig.prefs[themeColorKey]);
  Color themeTextColor = Color(EzConfig.prefs[themeTextColorKey]);
  Color buttonColor = Color(EzConfig.prefs[buttonColorKey]);

  @override
  Widget build(BuildContext context) {
    double buttonSpacer = EzConfig.prefs[buttonSpacingKey] * 2;
    double dialogSpacer = EzConfig.prefs[dialogSpacingKey];

    return EzScaffold(
      backgroundDecoration: BoxDecoration(color: Color(EzConfig.prefs[backColorKey])),
      appBar: EzAppBar(title: Text('Style settings', style: getTextStyle(titleStyleKey))),
      body: standardWindow(
        context: context,
        background: imageBackground(EzConfig.prefs[backImageKey]),
        body: ezScrollView(
          children: [
            // Font Family
            EzFontSetting(),
            Container(height: buttonSpacer),

            // Font size
            EzSliderSetting(
              prefsKey: fontSizeKey,
              type: SettingType.fontSize,
              title: 'Font size',
              min: 12.0,
              max: 48.0,
              steps: 18,
            ),
            Container(height: buttonSpacer),

            // Margin
            EzSliderSetting(
              prefsKey: marginKey,
              type: SettingType.margin,
              title: 'Margin',
              min: 5.0,
              max: 35.0,
              steps: 12,
            ),
            Container(height: buttonSpacer),

            // Padding
            EzSliderSetting(
              prefsKey: paddingKey,
              type: SettingType.padding,
              title: 'Padding',
              min: 5.0,
              max: 25.0,
              steps: 8,
            ),
            Container(height: buttonSpacer),

            // Button spacing
            EzSliderSetting(
              prefsKey: buttonSpacingKey,
              type: SettingType.buttonSpacing,
              title: 'Button spacing',
              min: 10.0,
              max: 100.0,
              steps: 18,
            ),
            Container(height: buttonSpacer),

            // Dialog spacing
            EzSliderSetting(
              prefsKey: dialogSpacingKey,
              type: SettingType.dialogSpacing,
              title: 'Dialog spacing',
              min: 10.0,
              max: 100.0,
              steps: 18,
            ),
            Container(height: buttonSpacer),

            // Signal spacing
            EzSliderSetting(
              prefsKey: signalSpacingKey,
              type: SettingType.buttonSpacing,
              title: 'Signal spacing',
              min: 10.0,
              max: 100.0,
              steps: 18,
            ),
            Container(height: buttonSpacer),

            // Signal height
            EzSliderSetting(
              prefsKey: signalHeightKey,
              type: SettingType.buttonHeight,
              title: 'Signal height',
              min: 75,
              max: 200,
              steps: 5,
            ),
            Container(height: buttonSpacer),

            // Signal count height
            EzSliderSetting(
              prefsKey: signalCountHeightKey,
              type: SettingType.buttonHeight,
              title: 'Signal count height',
              min: 50,
              max: 100,
              steps: 10,
            ),
            Container(height: buttonSpacer),

            // Reset all style settings
            GestureDetector(
              onTap: () {
                ezDialog(
                  context: context,
                  title: 'Reset style?',
                  content: [
                    ezYesNo(
                      context: context,
                      onConfirm: () {
                        // Remove all color settings
                        EzConfig.preferences.remove(fontFamilyKey);
                        EzConfig.preferences.remove(fontSizeKey);
                        EzConfig.preferences.remove(marginKey);
                        EzConfig.preferences.remove(paddingKey);
                        EzConfig.preferences.remove(buttonSpacingKey);
                        EzConfig.preferences.remove(dialogSpacingKey);
                        EzConfig.preferences.remove(signalSpacingKey);
                        EzConfig.preferences.remove(signalHeightKey);
                        EzConfig.preferences.remove(signalCountHeightKey);

                        popScreen(context: context, pass: true);
                        popScreen(context: context, pass: true);
                      },
                      onDeny: () => popScreen(context: context),
                      axis: Axis.vertical,
                      spacer: dialogSpacer,
                    ),
                  ],
                  needsClose: false,
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
      ),
    );
  }
}
