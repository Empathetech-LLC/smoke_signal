import '../utils/constants.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';

class ImageSettingsScreen extends StatefulWidget {
  const ImageSettingsScreen({Key? key}) : super(key: key);

  @override
  _ImageSettingsState createState() => _ImageSettingsState();
}

class _ImageSettingsState extends State<ImageSettingsScreen> {
  Color themeColor = Color(AppConfig.prefs[themeColorKey]);
  Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);
  Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);

  @override
  Widget build(BuildContext context) {
    double buttonSpacer = AppConfig.prefs[buttonSpacingKey];
    double dialogSpacer = AppConfig.prefs[dialogSpacingKey];

    return EZScaffold(
      title: 'Image settings',
      backgroundColor: Color(AppConfig.prefs[backColorKey]),
      body: ezScrollView(
        children: [
          // Background
          ImageSetting(
            prefsKey: backImageKey,
            fullscreen: true,
            title: 'Background',
            credits: credits[AppConfig.prefs[backImageKey]] ?? 'Wherever you got it!',
          ),
          Container(height: buttonSpacer),

          // Signal
          ImageSetting(
            prefsKey: signalImageKey,
            fullscreen: false,
            title: 'Signal',
            credits: credits[AppConfig.prefs[signalImageKey]] ?? 'Wherever you got it!',
          ),
          Container(height: buttonSpacer),

          // Reset all image settings
          GestureDetector(
            onTap: () {
              ezDialog(
                context,
                title: 'Reset all images?',
                content: [
                  ezYesNo(
                    context,
                    onConfirm: () {
                      // Remove all color settings
                      AppConfig.preferences.remove(backImageKey);
                      AppConfig.preferences.remove(signalImageKey);

                      popScreen(context);
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
        centered: true,
      ),
    );
  }
}
