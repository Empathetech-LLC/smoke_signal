import '../setting-states/set-color.dart';
import '../setting-states/set-image.dart';
import '../utils/scaffolds.dart';
import '../setting-states/set-value.dart';
import '../utils/storage.dart';
import '../utils/text.dart';
import '../utils/custom-widgets.dart';
import '../user/user-api.dart';
import '../utils/constants.dart';

import 'package:flutter/material.dart';

class SignalSettings extends StatefulWidget {
  const SignalSettings({Key? key}) : super(key: key);

  @override
  _SignalSettingsState createState() => _SignalSettingsState();
}

class _SignalSettingsState extends State<SignalSettings> {
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

          //// Images

          ezList(
            'Image',
            [ImageSetting(prefsKey: signalImageKey, message: 'Signal')],
          ),

          //// Colors

          ezList(
            'Color',
            [
              // User hint: hold the buttons to reset the color
              Text('Hold to reset', style: getTextStyle(dialogContentStyle)),
              Container(height: padding),

              // Background color
              ColorSetting(
                toControl: signalsBackgroundColorKey,
                message: 'Background\n(no image)',
              ),
              Container(height: buttonSpacer),

              // Signals
              ColorSetting(toControl: watchingColorKey, message: 'Watching'),
              Container(height: buttonSpacer),
              ColorSetting(toControl: watchingTextColorKey, message: 'Watching text'),
              Container(height: buttonSpacer),

              ColorSetting(toControl: joinedColorKey, message: 'Joined'),
              Container(height: buttonSpacer),
              ColorSetting(toControl: joinedTextColorKey, message: 'Joined text'),
              Container(height: buttonSpacer),

              // Reset all signal color settings
              GestureDetector(
                onTap: () {
                  ezDialog(
                    context,
                    'Reset all colors?',
                    [
                      // Yes/no
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Yes
                          ezIconButton(
                            // Remove all color settings
                            () {
                              AppUser.preferences.remove(signalsBackgroundColorKey);
                              AppUser.preferences.remove(watchingColorKey);
                              AppUser.preferences.remove(watchingTextColorKey);
                              AppUser.preferences.remove(joinedColorKey);
                              AppUser.preferences.remove(joinedTextColorKey);

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

          //// Spacing

          ezList(
            'Spacing',
            [
              // Card height
              ValueSetting(
                prefsKey: signalHeightKey,
                title: 'Signal card height',
                min: 75,
                max: 200,
                steps: 5,
              ),
              Container(height: 0.5 * buttonSpacer),

              // Count height
              ValueSetting(
                prefsKey: signalCountHeightKey,
                title: 'Signal count height',
                min: 50,
                max: 100,
                steps: 10,
              ),
              Container(height: 0.5 * buttonSpacer),

              // Signal spacing
              ValueSetting(
                prefsKey: signalSpacingKey,
                title: 'Signal spacing',
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
      Color(AppUser.prefs[signalsBackgroundColorKey]),
    );
  }
}
