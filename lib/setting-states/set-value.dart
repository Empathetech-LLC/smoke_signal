import '../utils/constants.dart';
import '../utils/text.dart';
import '../utils/custom-widgets.dart';
import '../utils/helpers.dart';
import '../user/user-api.dart';

import 'package:flutter/material.dart';

class ValueSetting extends StatefulWidget {
  const ValueSetting({
    Key? key,
    required this.prefsKey,
    required this.title,
    required this.min,
    required this.max,
    required this.steps,
  }) : super(key: key);

  final String prefsKey;
  final String title;
  final double min;
  final double max;
  final int steps;

  @override
  _ValueSettingState createState() => _ValueSettingState();
}

class _ValueSettingState extends State<ValueSetting> {
  //// Initialize state

  late double currValue = AppUser.prefs[widget.prefsKey];
  late double defaultValue = appDefaults[widget.prefsKey];
  late double buttonSpacer = AppUser.prefs[buttonSpacingKey];

  //// Draw state

  // Return the widget build for the current value type
  List<Widget> preview() {
    switch (widget.prefsKey) {
      // Font size
      case fontSizeKey:
        return [
          Container(height: buttonSpacer),
          ezButton(
            () {},
            () {},
            Text(
              'Preview: $currValue',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: currValue),
            ),
          ),
          Container(height: buttonSpacer),
        ];

      // Button && signal spacing
      case buttonSpacingKey:
      case signalSpacingKey:
        return [
          ezCenterScroll(
            [
              SizedBox(height: currValue),
              ezButton(() {}, () {}, Text('Preview $currValue')),
              SizedBox(height: currValue),
              ezButton(() {}, () {}, Text('Preview $currValue')),
              SizedBox(height: currValue),
            ],
          ),
        ];

      // Dialog spacing
      case dialogSpacingKey:
        return [
          Container(height: buttonSpacer),
          ezButton(
            () => ezDialog(
              context,
              'Space preview',
              [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Button 1
                    ezButton(() {}, () {}, Text('Preview: $currValue')),
                    Container(height: currValue),

                    // Button 2
                    ezButton(() {}, () {}, Text('Preview: $currValue')),
                    Container(height: currValue),
                  ],
                ),
              ],
            ),
            () {},
            Text('Press me'),
          ),
          Container(height: buttonSpacer),
        ];

      // Signal height
      case signalHeightKey:
        return [
          Container(height: buttonSpacer),
          ezButton(
            () {},
            () {},
            Text(
              'Preview: $currValue',
              style: getTextStyle(watchingStyle),
              textAlign: TextAlign.center,
            ),
            ElevatedButton.styleFrom(
              backgroundColor: Color(AppUser.prefs[watchingColorKey]),
              foregroundColor: Color(AppUser.prefs[watchingColorKey]),
              padding: EdgeInsets.all(padding),
              fixedSize: Size(screenWidth(context), currValue),
            ),
          ),
          Container(height: buttonSpacer),
        ];

      // Signal count height
      case signalCountHeightKey:
        return [
          Container(height: buttonSpacer),
          ezButton(
            () {},
            () {},
            Text(
              'Preview: $currValue',
              style: getTextStyle(watchingStyle),
              textAlign: TextAlign.center,
            ),
            ElevatedButton.styleFrom(
              backgroundColor: Color(AppUser.prefs[watchingColorKey]),
              foregroundColor: Color(AppUser.prefs[watchingColorKey]),
              padding: EdgeInsets.all(padding),
              fixedSize: Size(screenWidth(context), currValue),
            ),
          ),
          Container(height: buttonSpacer),
        ];

      // Default
      default:
        return [Container(height: buttonSpacer)];
    }
  }

  // Build the list of widgets to draw based on the value type
  List<Widget> buildList() {
    List<Widget> toReturn = [Text(widget.title, style: getTextStyle(subTitleStyle))];

    toReturn.addAll(preview());

    toReturn.addAll([
      // Value slider
      Slider(
        value: currValue,
        min: widget.min,
        max: widget.max,
        divisions: widget.steps,
        label: currValue.toString(),
        onChanged: (double value) {
          // Just update the on screen value while sliding around
          setState(() {
            currValue = value;
          });
        },
        onChangeEnd: (double value) {
          // When finished, write the result
          if (value == defaultValue) {
            AppUser.preferences.remove(widget.prefsKey);
          } else {
            AppUser.preferences.setDouble(widget.prefsKey, value);
          }
        },
      ),
      Container(height: buttonSpacer),

      // Reset button
      ezIconButton(
        () {
          AppUser.preferences.remove(widget.prefsKey);
          setState(() {
            currValue = appDefaults[widget.prefsKey];
          });
        },
        () {},
        Icon(Icons.restore),
        Text('Reset: ' + appDefaults[widget.prefsKey].toString()),
      ),
      Container(height: buttonSpacer),
    ]);

    // Build time!
    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    // Font setting UI
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buildList(),
    );
  }
}
