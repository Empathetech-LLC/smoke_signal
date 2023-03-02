import '../utils/constants.dart';
import '../utils/custom-widgets.dart';
import '../user/user-api.dart';
import '../utils/text.dart';

import 'package:flutter/material.dart';

class FontFamilySetting extends StatefulWidget {
  const FontFamilySetting({Key? key}) : super(key: key);

  @override
  _FontFamilySettingState createState() => _FontFamilySettingState();
}

class _FontFamilySettingState extends State<FontFamilySetting> {
  //// Initialize state

  // Gather theme data
  late String defaultFontFamily = appDefaults[fontFamilyKey];
  late String currFontFamily = AppUser.prefs[fontFamilyKey];

  late TextStyle buttonTextStyle = getTextStyle(buttonStyle);
  late double buttonSpacer = AppUser.prefs[buttonSpacingKey];

  //// Define interaction methods

  // onPressed method for font picker button
  void chooseGoogleFont() {
    ezDialog(
      context,

      // Title
      'Choose a font',

      // Children
      myGoogleFonts
          .map(
            (String font) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Button with the title of the font in that font's style
                ezButton(
                  () {
                    AppUser.preferences.setString(fontFamilyKey, font);
                    setState(() {
                      currFontFamily = googleStyleAlias(font).fontFamily!;
                    });
                    Navigator.of(context).pop();
                  },
                  () {},
                  Text(
                    font,
                    textAlign: TextAlign.center,
                    style: googleStyleAlias(font),
                  ),
                ),
                Container(
                  height: buttonSpacer,
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  //// Draw state

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Font picker
        ezButton(
          chooseGoogleFont,
          () {},
          Text(
            'Choose font:\n$currFontFamily',
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: buttonTextStyle.fontSize,
              fontFamily: currFontFamily,
              color: buttonTextStyle.color,
            ),
          ),
        ),
        Container(height: buttonSpacer),

        // Font reset
        ezButton(
          () {
            AppUser.preferences.remove(fontFamilyKey);
            setState(() {
              currFontFamily = defaultFontFamily;
            });
          },
          () {},
          Text(
            'Reset font\n($defaultFontFamily)',
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: buttonTextStyle.fontSize,
              fontFamily: defaultFontFamily,
              color: buttonTextStyle.color,
            ),
          ),
        ),
      ],
    );
  }
}
