import '../utils/helpers.dart';
import '../utils/constants.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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

          //// Background settings

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

          //// Theme settings

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
                    [
                      // Yes/no buttons
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Yes
                          ezIconButton(
                            () {
                              AppConfig.preferences.remove(buttonColorKey);
                              AppConfig.preferences.remove(buttonTextColorKey);
                              AppConfig.preferences.remove(themeColorKey);
                              AppConfig.preferences.remove(buttonColorKey);
                              AppConfig.preferences.remove(backColorKey);

                              Navigator.of(context).pop();
                            },
                            () {},
                            Icon(Icons.check),
                            Icon(Icons.check),
                            Text('Yes'),
                          ),

                          // No
                          ezIconButton(
                            () => Navigator.of(context).pop(),
                            () {},
                            Icon(Icons.cancel),
                            Icon(Icons.cancel),
                            Text('No'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                child: Text('Reset all', style: getTextStyle(subTitleStyleKey)),
              ),
              Container(height: buttonSpacer),
            ],
          ),

          //// Font settings

          ezList(
            'Font',
            [
              // Font family
              Text('Font family', style: getTextStyle(subTitleStyleKey)),
              Container(height: buttonSpacer),

              FontFamilySetting(),
              Container(height: buttonSpacer),

              // Font size
              ValueSetting(
                prefsKey: fontSizeKey,
                title: 'Font size',
                min: 12.0,
                max: 48.0,
                steps: 18,
              ),
            ],
          ),

          //// Spacing settings

          ezList(
            'Spacing',
            [
              // Button spacing
              ValueSetting(
                prefsKey: buttonSpacingKey,
                title: 'Button spacing',
                min: 10.0,
                max: 100.0,
                steps: 18,
              ),
              Container(height: 0.5 * buttonSpacer),

              // Dialog spacing
              ValueSetting(
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
