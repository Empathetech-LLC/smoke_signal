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
    double dialogSpacer = AppConfig.prefs[dialogSpacingKey];

    return navWindow(
      context: context,

      // Styling
      backgroundImage: buildDecoration(AppConfig.prefs[backImageKey]),
      backgroundColor: Color(AppConfig.prefs[backColorKey]),

      // Body
      body: ezScrollView(
        children: [
          warningCard(
            context: context,
            warning: 'Changes won\'t take effect until restart',
          ),
          Container(height: buttonSpacer),
          ezList(
            title: 'Background',
            body: [
              // Background image
              ImageSetting(
                prefsKey: backImageKey,
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
            title: 'Colors',
            body: [
              // Theme
              ColorSetting(toControl: themeColorKey, message: 'Theme'),
              Container(height: buttonSpacer),
              ColorSetting(toControl: themeTextColorKey, message: 'Theme text'),
              Container(height: buttonSpacer),

              // Buttons
              ColorSetting(toControl: buttonColorKey, message: 'Buttons'),
              Container(height: buttonSpacer),
              ColorSetting(toControl: buttonTextColorKey, message: 'Button text'),
              Container(height: dialogSpacer),

              // User hint: hold the buttons to reset the color
              ezText(
                'Hold each to reset',
                style: getTextStyle(dialogContentStyleKey),
              ),
              Container(height: dialogSpacer),

              // Reset all app color settings
              GestureDetector(
                onTap: () {
                  ezDialog(
                    context: context,
                    title: 'Reset all theme colors?\n(including background)',
                    content: ezYesNo(
                      context: context,
                      onConfirm: () {
                        // Remove all color settings
                        AppConfig.preferences.remove(backColorKey);
                        AppConfig.preferences.remove(themeColorKey);
                        AppConfig.preferences.remove(themeTextColorKey);
                        AppConfig.preferences.remove(buttonColorKey);
                        AppConfig.preferences.remove(buttonTextColorKey);

                        Navigator.of(context).pop();
                      },
                      onDeny: () => Navigator.of(context).pop(),
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
          ezList(
            title: 'Font',
            body: [
              // Font family
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
            title: 'Spacing',
            body: [
              // Margin
              SliderSetting(
                prefsKey: marginKey,
                type: SettingType.margin,
                title: 'Margin',
                min: 5.0,
                max: 35.0,
                steps: 12,
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
                    // Remove all color settings
                    AppConfig.defaults.forEach((key, value) {
                      AppConfig.preferences.remove(key);
                    });

                    Navigator.of(context).pop();
                  },
                  onDeny: () => Navigator.of(context).pop(),
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
