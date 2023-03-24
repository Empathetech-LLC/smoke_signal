import 'constants.dart';
import 'validate.dart';
import '../user/user-api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Drawer standardDrawer(BuildContext context) {
  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

  return Drawer(
    backgroundColor: Color(AppConfig.prefs[themeColorKey]),
    child: ezScrollView(
      children: [
        // App icon
        DrawerHeader(
          child: CircleAvatar(
            backgroundImage: AssetImage(appIconPath),
            minRadius: 50,
            maxRadius: 50,
          ),
        ),

        // GoTo settings
        ezIconButton(
          action: () => Navigator.of(context).popAndPushNamed(
            settingsRoute,
            arguments: {indexArg: 0},
          ),
          icon: Icon(PlatformIcons(context).settings),
          message: 'Settings',
        ),
        Container(height: buttonSpacer),

        // Show input rules
        ezButton(
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
      ],
    ),
  );
}

Drawer signalBoardDrawer(BuildContext context) {
  double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

  return Drawer(
    backgroundColor: Color(AppConfig.prefs[themeColorKey]),
    child: ezScrollView(
      children: [
        // Header: User profile preview, edit button, logout button
        DrawerHeader(
          child: Row(
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
                    foregroundImage: CachedNetworkImageProvider(
                        AppUser.account.photoURL ?? defaultAvatarURL),
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
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Edit
                  ezButton(
                    action: () =>
                        Navigator.of(context).popAndPushNamed(profileSettingsRoute),
                    body: Icon(Icons.edit),
                  ),

                  // Logout
                  ezButton(
                    action: () => logout(context),
                    body: Icon(Icons.logout),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(height: buttonSpacer),

        // Add new signal
        ezIconButton(
          action: () => Navigator.of(context).popAndPushNamed(createSignalRoute),
          message: 'New',
          icon: Icon(PlatformIcons(context).add),
        ),
        Container(height: buttonSpacer),

        // GoTo settings
        ezIconButton(
          action: () => Navigator.of(context).popAndPushNamed(
            settingsRoute,
            arguments: {indexArg: 1},
          ),
          message: 'Settings',
          icon: Icon(PlatformIcons(context).settings),
        ),
        Container(height: buttonSpacer),

        // Show input rules
        ezButton(
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
      ],
    ),
  );
}
