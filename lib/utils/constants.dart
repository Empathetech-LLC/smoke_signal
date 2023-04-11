import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

/// Application title [String]
const String appTitle = 'Smoke Signal';

/// Paths to asset files for [EzConfig.assets]
final List<String> assets = [
  appIconPath,
  darkForestPath,
  smokeSignalPath,
];

/// Image path -> image source
final Map<String, String> credits = {
  appIconPath: 'Empathetech LLC: The Founder\n\nUnnamed',
  smokeSignalPath: 'https://pimen.itch.io/\n\n\'Smoke Effect\'',
  darkForestPath: 'https://edermunizz.itch.io/\n\n\'Dark Forest\'',
};

// Images
const String appIconPath = 'assets/app-icon.png';
const String darkForestPath = 'assets/dark-forest.png';
const String smokeSignalPath = 'assets/smoke-signal.gif';

// Shared Preferences keys
const String signalImageKey = 'signalImage';
const String signalSpacingKey = 'signalSpacing';
const String signalHeightKey = 'signalHeight';
const String signalCountHeightKey = 'signalCountHeight';
const String watchingColorKey = 'watchingSignalColor';
const String watchingTextColorKey = 'watchingSignalTextColor';
const String joinedColorKey = 'joinedSignalColor';
const String joinedTextColorKey = 'joinedSignalTextColor';

/// [Map] of default values for all Smoke Signal specific user customizable UI variables
/// Beyond those already present in [EzConfig] from empathetech_flutter_ui
final Map<String, dynamic> customDefaults = {
  backImageKey: darkForestPath,
  signalImageKey: smokeSignalPath,
  signalSpacingKey: 50.0,
  signalHeightKey: 125.0,
  signalCountHeightKey: 75.0,
  watchingColorKey: 0xE620DAA5, // Empathetech eucalyptus
  watchingTextColorKey: 0xFF000000, // Black text
  joinedColorKey: 0xE6A520DA, // Empathetech purple
  joinedTextColorKey: 0xFFFFFFFF, // White text
};
