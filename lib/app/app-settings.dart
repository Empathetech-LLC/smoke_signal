import '../setting-states/set-color.dart';
import '../setting-states/set-font.dart';
import '../setting-states/set-value.dart';
import '../setting-states/set-image.dart';
import '../utils/constants.dart';
import '../utils/storage.dart';
import '../utils/scaffolds.dart';
import '../utils/text.dart';
import '../utils/custom-widgets.dart';
import '../user/user-api.dart';

import 'package:flutter/material.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    double buttonSpacer = AppUser.prefs[buttonSpacingKey];

    return navWindow(
      context,

      // Body
      ezCenterScroll(
        [
          changesWarning(context),
          Container(height: buttonSpacer),

          //// Background settings

          ezList(
            'Image',
            [ImageSetting(prefsKey: backImageKey, message: 'Background')],
          ),

          //// Theme settings

          ezList(
            'Color',
            [
              // User hint: hold the buttons to reset the color
              Text('Hold to reset', style: getTextStyle(dialogContentStyle)),
              Container(height: padding),

              // Background
              ColorSetting(
                  toControl: appBackgroundColorKey, message: 'Background\n(no image)'),
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
                              AppUser.preferences.remove(buttonColorKey);
                              AppUser.preferences.remove(buttonTextColorKey);
                              AppUser.preferences.remove(themeColorKey);
                              AppUser.preferences.remove(buttonColorKey);
                              AppUser.preferences.remove(appBackgroundColorKey);

                              Navigator.of(context).pop();
                            },
                            () {},
                            Icon(Icons.check),
                            Text('Yes'),
                          ),

                          // No
                          ezIconButton(
                            () => Navigator.of(context).pop(),
                            () {},
                            Icon(Icons.cancel),
                            Text('No'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                child: Text('Reset all', style: getTextStyle(subTitleStyle)),
              ),
              Container(height: buttonSpacer),
            ],
          ),

          //// Font settings

          ezList(
            'Font',
            [
              // Font family
              Text('Font family', style: getTextStyle(subTitleStyle)),
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
      buildDecoration(AppUser.prefs[backImageKey]),

      // Fallback background color
      Color(AppUser.prefs[appBackgroundColorKey]),
    );
  }
}
