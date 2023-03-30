import 'constants.dart';
import 'validate.dart';
import '../user/user-api.dart';
import '../app/settings-screen.dart';
import '../user/profile-settings-screen.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// "Standard" drawer header
/// For use on screen in which settings should be available, but no user is logged in
Widget standardDrawerHeader() {
  return CircleAvatar(
    backgroundImage: AssetImage(appIconPath),
    minRadius: 50,
    maxRadius: 50,
  );
}

/// "Standard" drawer body
/// For use on screen in which settings should be available, but no user is logged in
List<Widget> standardDrawerBody(BuildContext context) {
  double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

  return [
    // GoTo settings
    EZButton.icon(
      action: () => popAndPushScreen(
        context: context,
        screen: SettingsScreen(),
      ),
      icon: ezIcon(PlatformIcons(context).settings),
      message: 'Settings',
    ),
    Container(height: buttonSpacer),

    // Show input rules
    EZButton(
      action: () => ezDialog(
        context: context,
        title: 'Input rules',
        content: Text(
          validatorRule,
          style: getTextStyle(dialogContentStyleKey),
          textAlign: TextAlign.center,
        ),
      ),
      body: Text('Input rules'),
    ),
    Container(height: buttonSpacer),
  ];
}

/// Custom drawer header for Signal Board
Widget signalDrawerHeader(BuildContext context) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      // Profile image and name
      Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Profile image
          CircleAvatar(
            foregroundImage:
                CachedNetworkImageProvider(AppUser.account.photoURL ?? defaultAvatarURL),
            minRadius: 50,
            maxRadius: 50,
          ),

          // Profile name
          Text(
            AppUser.account.displayName ?? defaultDisplayName,
            style: getTextStyle(dialogTitleStyleKey),
          ),
        ],
      ),

      // Edit and logout buttons
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Edit
          EZButton(
            action: () => popAndPushScreen(
              context: context,
              screen: ProfileSettingsScreen(),
            ),
            body: ezIcon(PlatformIcons(context).edit),
          ),
          Container(height: AppConfig.prefs[dialogSpacingKey]),

          // Logout
          EZButton(
            action: () => logout(context),
            body: ezIcon(Icons.logout),
          ),
        ],
      ),
    ],
  );
}
