import '../utils/constants.dart';
import '../user/user-api.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

// Custom signals board scaffold
signalBoardScaffold(BuildContext context, String title, Widget body, Function() refresh,
    Function() reload, DecorationImage? backgroundImage, Color backgroundColor) {
  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

  // Gesture detector makes it so keyboards close on screen tap
  return GestureDetector(
    onTap: () => AppConfig.focus.primaryFocus?.unfocus(),
    child: Scaffold(
      appBar: AppBar(title: PlatformText(title)),
      body: Container(
        width: screenWidth(context),
        height: screenHeight(context),
        decoration: BoxDecoration(
          color: backgroundColor,
          image: backgroundImage,
        ),

        // Wrapping the passed body in a margin'd container means UI code can always...
        // ...use the full context width && have consistent margins
        child: Container(
          child: body,
          margin: EdgeInsets.all(AppConfig.prefs[marginKey]),
        ),
      ),
      floatingActionButton: ezButton(
        refresh,
        reload,
        Icon(Icons.refresh),
      ),

      // Drawer aka settings hamburger
      endDrawer: Drawer(
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
                      PlatformText(
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
              PlatformText('New'),
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
              PlatformText('Settings'),
            ),
            Container(height: buttonSpacer),

            // Show input rules
            ezButton(
              () => ezDialog(
                context,
                'Input rules',
                [
                  PlatformText(
                    validatorRule,
                    style: getTextStyle(dialogContentStyleKey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              () {},
              PlatformText('Input rules'),
            ),
            Container(height: buttonSpacer),
          ],
        ),
      ),
    ),
  );
}

// End drawer with just a link to app settings
Drawer settingsDrawer(BuildContext context) {
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
          PlatformText('Settings'),
        ),
        Container(height: buttonSpacer),

        // Show input rules
        ezButton(
          () => ezDialog(
            context,
            'Input rules',
            [
              PlatformText(
                validatorRule,
                style: getTextStyle(dialogContentStyleKey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          () {},
          PlatformText('Input rules'),
        ),
        Container(height: buttonSpacer),
      ],
    ),
  );
}
