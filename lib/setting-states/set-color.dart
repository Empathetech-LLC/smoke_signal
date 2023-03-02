import '../utils/constants.dart';
import '../utils/custom-widgets.dart';
import '../utils/storage.dart';
import '../utils/helpers.dart';
import '../user/user-api.dart';
import '../utils/text.dart';

import 'package:flutter/material.dart';

class ColorSetting extends StatefulWidget {
  const ColorSetting({
    Key? key,
    required this.toControl,
    required this.message,
  }) : super(key: key);

  final String toControl;
  final String message;

  @override
  _ColorSettingState createState() => _ColorSettingState();
}

class _ColorSettingState extends State<ColorSetting> {
  //// Initialize state

  late Color currColor = Color(AppUser.prefs[widget.toControl]);

  // Gather theme data
  late Color themeColor = Color(AppUser.prefs[themeColorKey]);
  late Color themeTextColor = Color(AppUser.prefs[themeTextColorKey]);
  late Color buttonColor = Color(AppUser.prefs[buttonColorKey]);

  //// Define interaction methods

  // Edit button onPressed: update the color to whatever the user chooses
  void changeColor() {
    colorPicker(
      context,

      // Starting color
      currColor,

      // onColorChange
      (chosenColor) {
        setState(() {
          currColor = chosenColor;
        });
      },

      // Apply
      () {
        // Update the users setting
        AppUser.preferences.setInt(widget.toControl, currColor.value);
        Navigator.of(context).pop();
      },

      // Cancel
      () => Navigator.of(context).pop(),
    );
  }

  // Edit button onLongPress: reset the color to the app default
  void reset() {
    Color resetColor = Color(appDefaults[widget.toControl]);

    ezDialog(
      context,
      'Reset to...',
      [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Color preview
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: resetColor,
                foregroundColor: resetColor,
                shadowColor: resetColor,
                surfaceTintColor: resetColor,
                fixedSize: Size(75, 75),
              ),
              onPressed: () {},
              child: Container(),
            ),
            Container(height: AppUser.prefs[dialogSpacingKey]),

            // Yes/no buttons
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Yes
                ezIconButton(
                  () {
                    // Remove the users setting
                    AppUser.preferences.remove(widget.toControl);

                    setState(() {
                      currColor = resetColor;
                    });

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
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Color setting UI
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Color label
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: themeTextColor,
            foregroundColor: themeTextColor,
            padding: EdgeInsets.all(padding),
          ),
          onPressed: () {},
          child: Text(
            widget.message,
            style: getTextStyle(colorSettingStyle),
            textAlign: TextAlign.center,
          ),
        ),

        // Color preview/edit button
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: currColor,
            foregroundColor: buttonColor,
            side: BorderSide(color: buttonColor),
            fixedSize: Size(75, 75),
          ),
          onPressed: changeColor,
          onLongPress: reset,
          child: Icon(
            Icons.edit,
            color: getContrastText(currColor),
            size: 37.5,
          ),
        ),
      ],
    );
  }
}
