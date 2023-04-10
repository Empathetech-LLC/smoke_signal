import '../utils/utils.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';

class StyleSettingsScreen extends StatefulWidget {
  const StyleSettingsScreen({Key? key}) : super(key: key);

  @override
  _StyleSettingsState createState() => _StyleSettingsState();
}

class _StyleSettingsState extends State<StyleSettingsScreen> {
  Color themeColor = Color(AppConfig.prefs[themeColorKey]);
  Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);
  Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);

  @override
  Widget build(BuildContext context) {
    double buttonSpacer = AppConfig.prefs[buttonSpacingKey] * 2;
    double dialogSpacer = AppConfig.prefs[dialogSpacingKey];

    return EZScaffold(
      title: Text('Style settings', style: getTextStyle(titleStyleKey)),
      backgroundColor: Color(AppConfig.prefs[backColorKey]),
      backgroundImage: buildDecoration(AppConfig.prefs[backImageKey]),
      body: ezScrollView(
        children: [
          // Font Family
          FontFamilySetting(),
          Container(height: buttonSpacer),

          // Font size
          SliderSetting(
            prefsKey: fontSizeKey,
            type: SettingType.fontSize,
            title: 'Font size',
            min: 12.0,
            max: 48.0,
            steps: 18,
          ),
          Container(height: buttonSpacer),

          // Margin
          SliderSetting(
            prefsKey: marginKey,
            type: SettingType.margin,
            title: 'Margin',
            min: 5.0,
            max: 35.0,
            steps: 12,
          ),
          Container(height: buttonSpacer),

          // Padding
          SliderSetting(
            prefsKey: paddingKey,
            type: SettingType.padding,
            title: 'Padding',
            min: 5.0,
            max: 25.0,
            steps: 8,
          ),
          Container(height: buttonSpacer),

          // Button spacing
          SliderSetting(
            prefsKey: buttonSpacingKey,
            type: SettingType.buttonSpacing,
            title: 'Button spacing',
            min: 10.0,
            max: 100.0,
            steps: 18,
          ),
          Container(height: buttonSpacer),

          // Dialog spacing
          SliderSetting(
            prefsKey: dialogSpacingKey,
            type: SettingType.dialogSpacing,
            title: 'Dialog spacing',
            min: 10.0,
            max: 100.0,
            steps: 18,
          ),
          Container(height: buttonSpacer),

          // Signal spacing
          SliderSetting(
            prefsKey: signalSpacingKey,
            type: SettingType.buttonSpacing,
            title: 'Signal spacing',
            min: 10.0,
            max: 100.0,
            steps: 18,
          ),
          Container(height: buttonSpacer),

          // Signal height
          SliderSetting(
            prefsKey: signalHeightKey,
            type: SettingType.buttonHeight,
            title: 'Signal height',
            min: 75,
            max: 200,
            steps: 5,
          ),
          Container(height: buttonSpacer),

          // Signal count height
          SliderSetting(
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
                context,
                title: 'Reset style?',
                content: [
                  ezYesNo(
                    context,
                    onConfirm: () {
                      // Remove all color settings
                      AppConfig.preferences.remove(fontFamilyKey);
                      AppConfig.preferences.remove(fontSizeKey);
                      AppConfig.preferences.remove(marginKey);
                      AppConfig.preferences.remove(paddingKey);
                      AppConfig.preferences.remove(buttonSpacingKey);
                      AppConfig.preferences.remove(dialogSpacingKey);
                      AppConfig.preferences.remove(signalSpacingKey);
                      AppConfig.preferences.remove(signalHeightKey);
                      AppConfig.preferences.remove(signalCountHeightKey);

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
