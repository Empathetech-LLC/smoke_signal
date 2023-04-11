import '../utils/utils.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';

class ImageSettingsScreen extends StatefulWidget {
  const ImageSettingsScreen({Key? key}) : super(key: key);

  @override
  _ImageSettingsState createState() => _ImageSettingsState();
}

class _ImageSettingsState extends State<ImageSettingsScreen> {
  late Color themeColor = Color(EzConfig.prefs[themeColorKey]);
  late Color themeTextColor = Color(EzConfig.prefs[themeTextColorKey]);
  late Color buttonColor = Color(EzConfig.prefs[buttonColorKey]);

  late double buttonSpacer = EzConfig.prefs[buttonSpacingKey];

  @override
  Widget build(BuildContext context) {
    return EzScaffold(
      backgroundDecoration: BoxDecoration(color: Color(EzConfig.prefs[backColorKey])),
      appBar: EzAppBar(title: Text('Image settings', style: getTextStyle(titleStyleKey))),
      body: standardWindow(
        context: context,
        background: imageBackground(EzConfig.prefs[backImageKey]),
        body: ezScrollView(
          children: [
            // Background
            EzImageSetting(
              prefsKey: backImageKey,
              fullscreen: true,
              title: 'Background',
              credits: credits[EzConfig.prefs[backImageKey]] ?? 'Wherever you got it!',
              allowClear: true,
            ),
            Container(height: buttonSpacer),

            // Signal
            EzImageSetting(
              prefsKey: signalImageKey,
              fullscreen: false,
              title: 'Signal',
              credits: credits[EzConfig.prefs[signalImageKey]] ?? 'Wherever you got it!',
              allowClear: false,
            ),
            Container(height: buttonSpacer),
          ],
          centered: true,
        ),
      ),
    );
  }
}
