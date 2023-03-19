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
      ezCenterScroll(
        [
          warningCard(context, 'Changes won\'t take effect until restart'),
          Container(height: buttonSpacer),
          ezList(
            'Image',
            [
              ImageSetting(
                prefsKey: backImageKey,
                isAssetImage: isAssetImage(AppConfig.prefs[backImageKey]),
                title: 'Background',
                credits: credits[AppConfig.prefs[backImageKey]] ?? 'Wherever you got it!',
              )
            ],
          ),
          ezList(
            'Color',
            [
              // User hint: hold the buttons to reset the color
              Text('Hold to reset', style: getTextStyle(dialogContentStyleKey)),
              Container(height: AppConfig.prefs[paddingKey]),

              // Background
              ColorSetting(toControl: backColorKey, message: 'Background\n(no image)'),
              Container(height: buttonSpacer),

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
                    'Reset all colors?',
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
              // Button spacing
              SliderSetting(
                prefsKey: buttonSpacingKey,
                title: 'Button spacing',
                min: 10.0,
                max: 100.0,
                steps: 18,
              ),
              Container(height: 0.5 * buttonSpacer),

              // Dialog spacing
              SliderSetting(
                prefsKey: dialogSpacingKey,
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
