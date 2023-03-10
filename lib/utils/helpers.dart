import '../utils/text.dart';
import '../utils/constants.dart';

import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

// Get screen width
double screenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

// Get screen height
double screenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

// Get the opposite of the passed color
Color invertColor(Color toInvert) {
  final r = 255 - toInvert.red;
  final g = 255 - toInvert.green;
  final b = 255 - toInvert.blue;

  return Color.fromARGB((toInvert.opacity * 255).round(), r, g, b);
}

// Returns whether text with a background of the passed color should be black or white
Color getContrastPlatformText(Color background) {
  final r = background.red;
  final g = background.green;
  final b = background.blue;

  return (((r * 0.299) + (g * 0.587) + (b * 0.114)) >= 150) ? Colors.black : Colors.white;
}

// Validate emails with the community plugin
String? emailValidator(String? toCheck) {
  return (toCheck != null && !EmailValidator.validate(toCheck))
      ? 'Email does not exist'
      : null;
}

// Validate display names with the shared rules (in constants)
String? displayNameValidator(String? toCheck) {
  return (toCheck != null && !validatorRegex.hasMatch(toCheck))
      ? 'Invalid display name'
      : null;
}

// Validate urls with the built in tool
String? urlValidator(String? toCheck) {
  return (toCheck != null && !Uri.tryParse(toCheck)!.hasAbsolutePath)
      ? 'Invalid URL'
      : null;
}

// Validate signal titles with the shared rules (in constants)
String? signalTitleValidator(String? toCheck) {
  return (toCheck != null && !validatorRegex.hasMatch(toCheck)) ? 'Invalid title' : null;
}

// Validate signal notification messages with the shared rules (constants)
String? signalMessageValidator(String? toCheck) {
  return (toCheck != null && !validatorRegex.hasMatch(toCheck))
      ? 'Invalid message'
      : null;
}

// Log the passed message and display a snack bar/pop up for the user
void popNLog(BuildContext context, String message, [int seconds = 3]) {
  log(message);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(seconds: seconds),
      content: PlatformText(
        message,
        textAlign: TextAlign.center,
        style: getTextStyle(dialogContentStyle),
      ),
    ),
  );
}
