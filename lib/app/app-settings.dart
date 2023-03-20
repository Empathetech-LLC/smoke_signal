import '../utils/helpers.dart';
import '../utils/constants.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// [navWindow] containing the user's app specific customization options
class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

    return navWindow(
      context,

      // Body
      ezScrollView(
        [
          warningCard(context, 'Changes won\'t take effect until restart'),
          Container(height: buttonSpacer),
          ezList(
            'Background',
            [
              // Background image
              ImageSetting(
                prefsKey: AppConfig.prefs[backImageKey],
                isAssetImage: isAssetImage(AppConfig.prefs[backImageKey]),
                fullscreen: true,
                title: 'Image',
                credits: credits[AppConfig.prefs[backImageKey]] ?? 'Wherever you got it!',
              ),
              Container(height: buttonSpacer),

              // Backup color
              ColorSetting(toControl: backColorKey, message: 'Backup color'),
            ],
          ),
          ezList(
            'Colors',
            [
              // User hint: hold the buttons to reset the color
              Text('Hold buttons to reset', style: getTextStyle(dialogContentStyleKey)),
              Container(height: AppConfig.prefs[paddingKey]),

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

              // Reset all app color settings
              GestureDetector(
                onTap: () {
                  ezDialog(
                    context,
                    'Reset all theme colors?\n(including background)',
                    ezYesNoRow(
                      context,
                      // On yes, remove all color settings
                      () {
                        AppConfig.preferences.remove(buttonColorKey);
                        AppConfig.preferences.remove(buttonTextColorKey);
                        AppConfig.preferences.remove(themeColorKey);
                        AppConfig.preferences.remove(buttonColorKey);
                        AppConfig.preferences.remove(backColorKey);

                        Navigator.of(context).pop();
                      },

                      // On no
                      () => Navigator.of(context).pop(),
                    ),
                  );
                },
                child: Text('Reset all', style: getTextStyle(subTitleStyleKey)),
              ),
              Container(height: buttonSpacer),
            ],
          ),
          ezList(
            'Font',
            [
              // Font family
              Text('Font family', style: getTextStyle(subTitleStyleKey)),
              Container(height: buttonSpacer),

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
            ],
          ),
          ezList(
            'Spacing',
            [
              // Margin
              SliderSetting(
                prefsKey: marginKey,
                type: SettingType.margin,
                title: 'Margin',
                min: 5.0,
                max: 25.0,
                steps: 8,
              ),

              // Padding
              SliderSetting(
                prefsKey: paddingKey,
                type: SettingType.padding,
                title: 'Padding',
                min: 5.0,
                max: 25.0,
                steps: 8,
              ),

              // Button spacing
              SliderSetting(
                prefsKey: buttonSpacingKey,
                type: SettingType.buttonSpacing,
                title: 'Button spacing',
                min: 10.0,
                max: 100.0,
                steps: 18,
              ),
              Container(height: 0.5 * buttonSpacer),

              // Dialog spacing
              SliderSetting(
                prefsKey: dialogSpacingKey,
                type: SettingType.dialogSpacing,
                title: 'Dialog spacing',
                min: 10.0,
                max: 100.0,
                steps: 18,
              ),
            ],
          ),
        ],
      ),

      // Background image/decoration
      buildDecoration(AppConfig.prefs[backImageKey]),

      // Fallback background color
      Color(AppConfig.prefs[backColorKey]),
    );
  }
}
