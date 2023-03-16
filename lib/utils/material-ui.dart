import '../user/user-api.dart';
import 'constants.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Drawer standardDrawer(BuildContext context) {
  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

  return Drawer(
    backgroundColor: Color(AppConfig.prefs[themeColorKey]),
    child: ezScrollView(
      [
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
          () => Navigator.of(context).popAndPushNamed(
            settingsRoute,
            arguments: {indexArg: 0},
          ),
          () {},
          Icon(Icons.edit),
          Icon(Icons.edit),
          Text('Settings'),
        ),
        Container(height: buttonSpacer),

        // Show input rules
        ezButton(
          () => ezDialog(
            context,
            'Input rules',
            [
              Text(
                validatorRule,
                style: getTextStyle(dialogContentStyleKey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          () {},
          Text('Input rules'),
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
      [
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
                    () => Navigator.of(context).popAndPushNamed(profileSettingsRoute),
                    () {},
                    Icon(Icons.edit),
                  ),

                  // Logout
                  ezButton(
                    () => logout(context),
                    () {},
                    Icon(Icons.logout),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(height: buttonSpacer),

        // Add new signal
        ezIconButton(
          () => Navigator.of(context).popAndPushNamed(createSignalRoute),
          () {},
          Icon(Icons.add),
          Icon(Icons.add),
          Text('New'),
        ),
        Container(height: buttonSpacer),

        // GoTo settings
        ezIconButton(
          () => Navigator.of(context).popAndPushNamed(
            settingsRoute,
            arguments: {indexArg: 1},
          ),
          () {},
          Icon(Icons.settings),
          Icon(Icons.settings),
          Text('Settings'),
        ),
        Container(height: buttonSpacer),

        // Show input rules
        ezButton(
          () => ezDialog(
            context,
            'Input rules',
            [
              Text(
                validatorRule,
                style: getTextStyle(dialogContentStyleKey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          () {},
          Text('Input rules'),
        ),
        Container(height: buttonSpacer),
      ],
    ),
  );
}
