import '../utils/helpers.dart';
import '../utils/constants.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SignalSettings extends StatefulWidget {
  const SignalSettings({Key? key}) : super(key: key);

  @override
  _SignalSettingsState createState() => _SignalSettingsState();
}

class _SignalSettingsState extends State<SignalSettings> {
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

          //// Images

          ezList(
            'Image',
            [
              ImageSetting(
                prefsKey: signalImageKey,
                isAssetImage: isAssetImage(AppConfig.prefs[signalImageKey]),
                title: 'Signal',
                credits:
                    credits[AppConfig.prefs[signalImageKey]] ?? 'Wherever you got it!',
              )
            ],
          ),

          //// Colors

          ezList(
            'Color',
            [
              // User hint: hold the buttons to reset the color
              Text('Hold to reset', style: getTextStyle(dialogContentStyleKey)),
              Container(height: AppConfig.prefs[paddingKey]),

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
                              AppConfig.preferences.remove(signalsBackgroundColorKey);
                              AppConfig.preferences.remove(watchingColorKey);
                              AppConfig.preferences.remove(watchingTextColorKey);
                              AppConfig.preferences.remove(joinedColorKey);
                              AppConfig.preferences.remove(joinedTextColorKey);

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
      buildDecoration(AppConfig.prefs[backImageKey]),

      // Fallback background color
      Color(AppConfig.prefs[signalsBackgroundColorKey]),
    );
  }
}
