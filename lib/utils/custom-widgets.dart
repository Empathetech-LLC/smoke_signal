import '../utils/constants.dart';
import '../utils/storage.dart';
import '../utils/text.dart';
import '../utils/helpers.dart';
import '../user/user-api.dart';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

//// General styling

// Blank border for text fields
UnderlineInputBorder blankBorder() {
  return UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent));
}

// Button style for making outlined buttons look like text field boxes
ButtonStyle textFieldStyle() {
  return OutlinedButton.styleFrom(
    side: BorderSide(color: Color(AppUser.prefs[buttonColorKey])),
    backgroundColor: Color(AppUser.prefs[themeColorKey]),
    foregroundColor: Color(AppUser.prefs[buttonColorKey]),
    textStyle: getTextStyle(dialogContentStyle),
    padding: EdgeInsets.all(padding),
  );
}

// Button style for the general use elevated button
ButtonStyle defaultButton() {
  return ElevatedButton.styleFrom(
    backgroundColor: Color(AppUser.prefs[buttonColorKey]),
    foregroundColor: Color(AppUser.prefs[buttonTextColorKey]),
    textStyle: getTextStyle(buttonStyle),
    padding: EdgeInsets.all(padding),
  );
}

// Button style for a circular elevated button
ButtonStyle circleButton() {
  return ElevatedButton.styleFrom(
    backgroundColor: Color(AppUser.prefs[buttonColorKey]),
    foregroundColor: Color(AppUser.prefs[buttonTextColorKey]),
    textStyle: getTextStyle(buttonStyle),
    padding: EdgeInsets.all(padding),
    shape: CircleBorder(),
  );
}

//// Static widgets

// Standard text box
// Non-interactive and unstyled, wrap in something else for style
Widget paddedPlatformText(String text, String textStyle, [TextAlign? alignment]) {
  return Container(
    padding: EdgeInsets.all(padding),
    child: PlatformText(
      text,
      style: getTextStyle(textStyle),
      textAlign: alignment,
    ),
  );
}

// Standard title card (non-interactive)
Widget titleCard(String title, [String? style]) {
  return Card(
    color: Color(AppUser.prefs[themeColorKey]),
    child: paddedPlatformText(title, style ?? titleStyle),
  );
}

// The word loading with an elipses of smoke signals
Widget loadingMessage(BuildContext context) {
  // Gather theme data
  double imageSize = getTextStyle(titleStyle).fontSize!;

  SizedBox elipsis = SizedBox(
    height: imageSize,
    width: imageSize,
    child: buildImage(smokeSignalPath),
  );

  return Container(
    child: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PlatformText('Loading ', style: getTextStyle(titleStyle)),
          elipsis,
          PlatformText(' ', style: getTextStyle(titleStyle)),
          elipsis,
          PlatformText(' ', style: getTextStyle(titleStyle)),
          elipsis,
        ],
      ),
    ),
  );
}

// Title card for setting pages, warns the user that the changes won't take effect...
// until the app restarts
Widget changesWarning(BuildContext context) {
  return Card(
    color: Color(AppUser.prefs[themeColorKey]),
    child: Container(
      width: screenWidth(context),
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.warning, color: Colors.amber),
              PlatformText('WARNING', style: getTextStyle(dialogTitleStyle)),
              Icon(Icons.warning, color: Colors.amber),
            ],
          ),
          Container(height: padding),
          PlatformText(
            'Changes won\'t take effect until restart',
            style: getTextStyle(dialogContentStyle),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

//// Interactive widgets

// Returns an standard elevated button wrapped in a container
Widget ezButton(void Function() action, void Function() longAction, Widget body,
    [ButtonStyle? buttonStyle]) {
  return ElevatedButton(
    style: buttonStyle == null ? defaultButton() : buttonStyle,
    onPressed: action,
    onLongPress: longAction,
    child: body,
  );
}

// Ditto but with an icon button
Widget ezIconButton(
    void Function() action, void Function() longAction, Icon icon, Widget body,
    [ButtonStyle? buttonStyle]) {
  return ElevatedButton.icon(
    style: buttonStyle == null ? defaultButton() : buttonStyle,
    onPressed: action,
    onLongPress: longAction,
    icon: icon,
    label: body,
  );
}

// Saves time on standardizing the dialog's padding
void ezDialog(BuildContext context, String? title, List<Widget> build) {
  double dialogSpacer = AppUser.prefs[dialogSpacingKey];
  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      insetPadding: EdgeInsets.all(padding),
      title: title == null ? null : PlatformText(title, textAlign: TextAlign.center),
      titlePadding: title == null
          ? EdgeInsets.zero
          : EdgeInsets.only(
              top: dialogSpacer,
              left: padding,
              right: padding,
            ),
      contentPadding: EdgeInsets.only(
        top: dialogSpacer,
        bottom: dialogSpacer,
        left: padding,
        right: padding,
      ),
      children: build,
    ),
  );
}

// Saves time on creating scroll views
Widget ezScrollView(List<Widget> children,
    [MainAxisSize axisSize = MainAxisSize.min,
    MainAxisAlignment axisAlign = MainAxisAlignment.spaceEvenly,
    Axis direction = Axis.vertical]) {
  return SingleChildScrollView(
    physics: BouncingScrollPhysics(),
    scrollDirection: direction,
    child: direction == Axis.vertical
        ? Column(
            mainAxisSize: axisSize,
            mainAxisAlignment: axisAlign,
            children: children,
          )
        : Row(
            mainAxisSize: axisSize,
            mainAxisAlignment: axisAlign,
            children: children,
          ),
  );
}

// Ditto
Widget ezCenterScroll(List<Widget> children,
    [MainAxisSize axisSize = MainAxisSize.min,
    MainAxisAlignment axisAlign = MainAxisAlignment.spaceEvenly,
    Axis direction = Axis.vertical]) {
  return Center(
    child: SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      scrollDirection: direction,
      child: direction == Axis.vertical
          ? Column(
              mainAxisSize: axisSize,
              mainAxisAlignment: axisAlign,
              children: children,
            )
          : Row(
              mainAxisSize: axisSize,
              mainAxisAlignment: axisAlign,
              children: children,
            ),
    ),
  );
}

// Dynamically styled dropdown list
Widget ezList(String title, List<Widget> body, [bool open = false]) {
  Color themeColor = Color(AppUser.prefs[themeColorKey]);
  Color themeTextColor = Color(AppUser.prefs[themeTextColorKey]);

  return ExpansionTile(
    tilePadding: EdgeInsets.all(padding),
    childrenPadding: EdgeInsets.only(left: padding, right: padding),
    collapsedBackgroundColor: themeColor,
    collapsedTextColor: themeTextColor,
    collapsedIconColor: themeTextColor,
    backgroundColor: themeColor,
    textColor: themeTextColor,
    iconColor: themeTextColor,
    title: PlatformText(title, style: getTextStyle(titleStyle)),
    children: body,
    initiallyExpanded: open,
    onExpansionChanged: (bool open) => AppUser.focus.primaryFocus?.unfocus(),
  );
}
