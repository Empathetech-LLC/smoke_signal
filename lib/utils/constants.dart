import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

/// Application title
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

// Shared Preferences
// aka for [customDefaults] for [AppConfig] from empathetech_flutter_ui
const String signalsBackgroundColorKey = 'signalsBackgroundColor';
const String signalImageKey = 'signalImage';
const String signalSpacingKey = 'signalSpacing';
const String signalHeightKey = 'signalHeight';
const String signalCountHeightKey = 'signalCountHeight';
const String watchingColorKey = 'watchingSignalColor';
const String watchingTextColorKey = 'watchingSignalTextColor';
const String joinedColorKey = 'joinedSignalColor';
const String joinedTextColorKey = 'joinedSignalTextColor';

final Map<String, dynamic> customDefaults = {
  fontFamilyKey: 'Roboto',
  fontSizeKey: 24.0,
  buttonSpacingKey: 35.0,
  dialogSpacingKey: 20.0,
  buttonColorKey: 0xE6DAA520,
  buttonTextColorKey: 0xFF000000,
  themeColorKey: 0xFF141414,
  themeTextColorKey: 0xFFFFFFFF,
  backImageKey: darkForestPath,
  backColorKey: 0xE6A520DA,
  signalsBackgroundColorKey: 0xE6A520DA,
  signalImageKey: smokeSignalPath,
  signalSpacingKey: 50.0,
  signalHeightKey: 125.0,
  signalCountHeightKey: 75.0,
  watchingColorKey: 0xE620DAA5,
  watchingTextColorKey: 0xFF000000,
  joinedColorKey: 0xE6DAA520,
  joinedTextColorKey: 0xFF000000,
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
