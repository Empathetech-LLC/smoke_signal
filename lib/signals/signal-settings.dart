import '../utils/constants.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
      context: context,

      body: ezScrollView(
        children: [
          warningCard(
            context: context,
            content: 'Changes won\'t take effect until restart',
          ),
          Container(height: buttonSpacer),

          //// Images

          ezList(
            title: 'Signal',
            body: [
              ImageSetting(
                prefsKey: signalImageKey,
                fullscreen: false,
                title: 'Image',
                credits:
                    credits[AppConfig.prefs[signalImageKey]] ?? 'Wherever you got it!',
              )
            ],
          ),

          //// Colors

          ezList(
            title: 'Colors',
            body: [
              // Signals
              ColorSetting(toControl: watchingColorKey, message: 'Watching'),
              Container(height: buttonSpacer),
              ColorSetting(toControl: watchingTextColorKey, message: 'Watching text'),
              Container(height: buttonSpacer),

              ColorSetting(toControl: joinedColorKey, message: 'Joined'),
              Container(height: buttonSpacer),
              ColorSetting(toControl: joinedTextColorKey, message: 'Joined text'),
              Container(height: buttonSpacer),

              // User hint: hold the buttons to reset the color
              paddedText(
                'Hold each to reset',
                style: getTextStyle(dialogContentStyleKey),
              ),
              Container(height: AppConfig.prefs[paddingKey]),

              // Reset all signal color settings
              GestureDetector(
                onTap: () {
                  ezDialog(
                    context: context,
                    title: 'Reset all signal colors?',
                    content: ezYesNo(
                        context: context,
                        onConfirm: () {
                          // Remove all color settings
                          AppConfig.preferences.remove(watchingColorKey);
                          AppConfig.preferences.remove(watchingTextColorKey);
                          AppConfig.preferences.remove(joinedColorKey);
                          AppConfig.preferences.remove(joinedTextColorKey);

                          Navigator.of(context).pop();
                        },
                        onDeny: () => Navigator.of(context).pop(),
                        axis: Axis.vertical,
                        spacer: AppConfig.prefs[dialogSpacingKey]),
                  );
                },
                child: paddedText(
                  'Reset all',
                  style: getTextStyle(subTitleStyleKey),
                ),
              ),
            ],
          ),

          //// Spacing

          ezList(
            title: 'Spacing',
            body: [
              // Card height
              SliderSetting(
                prefsKey: signalHeightKey,
                type: SettingType.buttonHeight,
                title: 'Signal card height',
                min: 75,
                max: 200,
                steps: 5,
              ),
              Container(height: buttonSpacer),

              // Count height
              SliderSetting(
                prefsKey: signalCountHeightKey,
                type: SettingType.buttonHeight,
                title: 'Signal count height',
                min: 50,
                max: 100,
                steps: 10,
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
            ],
          ),
          Container(height: buttonSpacer),

          // Reset all signal settings
          GestureDetector(
            onTap: () {
              ezDialog(
                context: context,
                title: 'Reset all signal settings?',
                content: ezYesNo(
                  context: context,
                  onConfirm: () {
                    // Remove all color settings
                    customDefaults.forEach((key, value) {
                      AppConfig.preferences.remove(key);
                    });

                    Navigator.of(context).pop();
                  },
                  onDeny: () => Navigator.of(context).pop(),
                  axis: Axis.vertical,
                  spacer: AppConfig.prefs[dialogSpacingKey],
                ),
              );
            },
            child: paddedText(
              'Reset all',
              style: getTextStyle(subTitleStyleKey),
            ),
          ),
        ],
      ),

      // Background image/decoration
      backgroundImage: buildDecoration(AppConfig.prefs[backImageKey]),

      // Fallback background color
      backgroundColor: Color(AppConfig.prefs[backColorKey]),
    );
  }
}
