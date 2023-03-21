import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

/// Application title [String]
const String appTitle = 'Smoke Signal';

/// Image path -> image source key -> value pair
final Map<String, String> credits = {
  appIconPath: 'Empathetech LLC: The Founder\n\nUnnamed',
  smokeSignalPath: 'https://pimen.itch.io/\n\n\'Smoke Effect\'',
  darkForestPath: 'https://edermunizz.itch.io/\n\n\'Dark Forest\'',
};

// Routes
const String signupRoute = 'sign-up-screen';
const String loginRoute = 'login-screen';
const String resetPasswordRoute = 'reset-password-screen';
const String homeRoute = 'home-screen';
const String settingsRoute = 'settings-screen';
const String profileSettingsRoute = 'profile-settings-screen';
const String signalMembersRoute = 'signal-members-screen';
const String createSignalRoute = 'create-signal-screen';

// Images
const String appIconPath = 'assets/app-icon.png';
const String darkForestPath = 'assets/dark-forest.png';
const String smokeSignalPath = 'assets/smoke-signal.gif';

// Navigator arguments
const String indexArg = 'index';
const String titleArg = 'title';
const String membersArg = 'members';
const String activeMembersArg = 'activeMembers';
const String memberReqsArg = 'memberReqs';
const String unaddedArg = 'unadded';
const String streamArg = 'stream';

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
/// Beyond those already present in [AppConfig] from empathetech_flutter_ui
final Map<String, dynamic> customDefaults = {
  fontFamilyKey: 'Roboto',
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

// Firebase users
const String usersPath = 'users';
const String fcmTokenPath = 'fcmToken';
const String displayNamePath = 'displayName';
const String avatarURLPath = 'avatarURL';
const String defaultDisplayName = 'Anon';
const String defaultAvatarURL =
    'https://raw.githubusercontent.com/Empathetech-LLC/smoke_signal/main/assets/app-icon.png';

// Firebase signals
const String signalsPath = 'signals';
const String messagePath = 'message';
const String activeMembersPath = 'activeMembers';
const String membersPath = 'members';
const String ownerPath = 'owner';
const String memberReqsPath = 'memberReqs';

// Firebase functions
const String sendPushFunc = 'sendPush';
const String tokenSeparator = ';me;';

const String tokenData = 'tokens';
const String titleData = 'title';
const String bodyData = 'body';
