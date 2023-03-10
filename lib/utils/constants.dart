//// UI

const double margin = 15.0;
const double padding = 12.5;

const double defaultSignalHeight = 100.0;

const String appTitle = 'Smoke Signal';

final Map<String, String> credits = {
  appIconPath: 'Empathetech LLC: The Founder\n\nUnnamed',
  noneIconPath: 'https://www.freepik.com/\n\n\'Forbidden\'',
  loadingGifPath: 'https://www.freepik.com/\n\n\'Loading\'',
  smokeSignalPath: 'https://pimen.itch.io/\n\n\'Smoke Effect\'',
  darkForestPath: 'https://edermunizz.itch.io/\n\n\'Dark Forest\'',
};

//// Paths

// Routes
const String signupRoute = '/user/sign-up-screen';
const String loginRoute = '/user/login-screen';
const String resetPasswordRoute = '/user/reset-password-screen';
const String homeRoute = '/app/home-screen';
const String settingsRoute = '/app/settings-screen';
const String profileSettingsRoute = '/user/profile-settings-screen';
const String signalMembersRoute = '/signals/signal-members-screen';
const String createSignalRoute = '/signals/create-signal-screen';

// Images
const String appIconPath = 'assets/app-icon.png';
const String noneIconPath = 'assets/none.png';
const String darkForestPath = 'assets/dark-forest.png';
const String loadingGifPath = 'assets/loading.gif';
const String smokeSignalPath = 'assets/smoke-signal.gif';

// Navigator arguments
const String indexArg = 'index';
const String titleArg = 'title';
const String membersArg = 'members';
const String activeMembersArg = 'activeMembers';
const String memberReqsArg = 'memberReqs';
const String unaddedArg = 'unadded';
const String streamArg = 'stream';

//// Shared Preferences

// Shared
const String fontFamilyKey = 'fontFamily';
const String fontSizeKey = 'fontSize';
const String buttonSpacingKey = 'buttonSpacing';
const String dialogSpacingKey = 'dialogSpacing';
const String buttonColorKey = 'buttonColor';
const String buttonTextColorKey = 'buttonTextColor';
const String themeColorKey = 'themeColor';
const String themeTextColorKey = 'themeTextColor';

// Base
const String backImageKey = 'backImage';
const String appBackgroundColorKey = 'appBackgroundColor';

// Signals
const String signalsBackgroundColorKey = 'signalsBackgroundColor';
const String signalImageKey = 'signalImage';
const String signalSpacingKey = 'signalSpacing';
const String signalHeightKey = 'signalHeight';
const String signalCountHeightKey = 'signalCountHeight';
const String watchingColorKey = 'watchingSignalColor';
const String watchingTextColorKey = 'watchingSignalTextColor';
const String joinedColorKey = 'joinedSignalColor';
const String joinedTextColorKey = 'joinedSignalTextColor';

final Map<String, dynamic> appDefaults = {
  fontFamilyKey: 'Roboto',
  fontSizeKey: 24.0,
  buttonSpacingKey: 35.0,
  dialogSpacingKey: 20.0,
  buttonColorKey: 0xE6DAA520,
  buttonTextColorKey: 0xFF000000,
  themeColorKey: 0xFF141414,
  themeTextColorKey: 0xFFFFFFFF,
  backImageKey: darkForestPath,
  appBackgroundColorKey: 0xE6A520DA,
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

//// Firebase

// Validators
const String validatorRule = """For display names, signal titles, and signal messages...

- Length 3 -> 20
- Can contain word characters (upper or lowercase)
- Can contain digits
- Can contain -_!?^,
- Can contain whitespace""";
final RegExp validatorRegex = new RegExp(r'^[\d\w\s-_!,?^]{3,20}$');

// User
const String usersPath = 'users';
const String fcmTokenPath = 'fcmToken';
const String displayNamePath = 'displayName';
const String avatarURLPath = 'avatarURL';
const String defaultDisplayName = 'Anon';
const String defaultAvatarURL =
    'https://raw.githubusercontent.com/Empathetech-LLC/smoke_signal/main/assets/app-icon.png';

// Signals
const String signalsPath = 'signals';
const String messagePath = 'message';
const String activeMembersPath = 'activeMembers';
const String membersPath = 'members';
const String ownerPath = 'owner';
const String memberReqsPath = 'memberReqs';

// Cloud functions
const String sendPushFunc = 'sendPush';
const String tokenSeparator = ';me;';

const String tokenData = 'tokens';
const String titleData = 'title';
const String bodyData = 'body';
