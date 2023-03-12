import 'package:email_validator/email_validator.dart';

const String validatorRule = """For display names, signal titles, and signal messages...

- Length 3 -> 20
- Can contain word characters (upper or lowercase)
- Can contain digits
- Can contain -_!?^,
- Can contain whitespace""";

final RegExp validatorRegex = new RegExp(r'^[\d\w\s-_!,?^]{3,20}$');

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
