import 'constants.dart';
import '../screens/app-settings.dart';
import '../screens/profile-settings.dart';

import 'package:empathetech_ss_api/empathetech_ss_api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// "Standard" drawer header: circle avatar of the app's icon
/// For use on screen in which settings should be available, but no user is logged in
Widget standardDrawerHeader() {
  return CircleAvatar(
    backgroundImage: AssetImage(appIconPath),
    minRadius: 50,
    maxRadius: 50,
  );
}

/// "Standard" drawer body: GoTo settings and show input rules
/// For use on screen in which settings should be available, but no user is logged in
List<Widget> standardDrawerBody(
  BuildContext context, {
  void Function()? onReturn,
}) {
  double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

  return [
    // GoTo settings
    EZButton.icon(
      action: () async {
        bool doAction = await popAndPushScreen(
          context,
          screen: AppSettingsScreen(),
        );

        if (doAction && onReturn != null) onReturn();
      },
      icon: ezIcon(PlatformIcons(context).settings),
      message: 'Settings',
    ),
    Container(height: buttonSpacer),

    // Show input rules
    EZButton(
      action: () => ezDialog(
        context,
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
/// Show profile information, GoTo profile settings, and logout
Widget signalDrawerHeader(
  BuildContext context, {
  required void Function() refresh,
}) {
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
            action: () async {
              bool shouldRefresh = await popAndPushScreen(
                context,
                screen: ProfileSettingsScreen(),
              );

              if (shouldRefresh) refresh();
            },
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
