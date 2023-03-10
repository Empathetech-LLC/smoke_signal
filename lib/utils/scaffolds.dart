import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/text.dart';
import '../utils/custom-widgets.dart';
import '../user/user-api.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

//// Full screens

// Standard full screen scaffold
Widget standardScaffold(BuildContext context, String title, Widget body,
    DecorationImage? backgroundImage, Color backgroundColor, Drawer? hamburger) {
  // Gesture detector makes it so keyboards close on screen tap
  return GestureDetector(
    onTap: () => AppUser.focus.primaryFocus?.unfocus(),
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
          margin: EdgeInsets.all(margin),
        ),
      ),
      endDrawer: hamburger,
    ),
  );
}

// Custom signals board scaffold
signalBoardScaffold(BuildContext context, String title, Widget body, Function() refresh,
    Function() reload, DecorationImage? backgroundImage, Color backgroundColor) {
  late double buttonSpacer = AppUser.prefs[buttonSpacingKey];

  // Gesture detector makes it so keyboards close on screen tap
  return GestureDetector(
    onTap: () => AppUser.focus.primaryFocus?.unfocus(),
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
          margin: EdgeInsets.all(margin),
        ),
      ),
      floatingActionButton: ezButton(
        refresh,
        reload,
        Icon(Icons.refresh),
        circleButton(),
      ),

      // Drawer aka settings hamburger
      endDrawer: Drawer(
        backgroundColor: Color(AppUser.prefs[themeColorKey]),
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
                        backgroundImage: AssetImage(loadingGifPath),
                        foregroundImage: CachedNetworkImageProvider(
                            AppUser.account.photoURL ?? defaultAvatarURL),
                        minRadius: 50,
                        maxRadius: 50,
                      ),

                      // Profile name
                      PlatformText(
                        AppUser.account.displayName ?? defaultDisplayName,
                        style: getTextStyle(dialogTitleStyle),
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
                        circleButton(),
                      ),

                      // Logout
                      ezButton(
                        () => logout(context),
                        () {},
                        Icon(Icons.logout),
                        circleButton(),
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
                    style: getTextStyle(dialogContentStyle),
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

//// Navigatable screens

// Outer screen
Widget navScaffold(BuildContext context, String title, Widget body, Drawer? hamburger,
    BottomNavigationBar navBar) {
  // Gesture detector makes it so keyboards close on screen tap
  return GestureDetector(
    onTap: () => AppUser.focus.primaryFocus?.unfocus(),
    child: Scaffold(
      appBar: AppBar(title: PlatformText(title)),
      body: body,
      endDrawer: hamburger,
      bottomNavigationBar: navBar,
    ),
  );
}

// Inner screen
Widget navWindow(BuildContext context, Widget body, DecorationImage? backgroundImage,
    Color backgroundColor) {
  return Container(
    height: screenHeight(context),
    width: screenWidth(context),
    decoration: BoxDecoration(
      color: backgroundColor,
      image: backgroundImage,
    ),

    // Wrapping the passed body in a margin'd container means UI code can always...
    // ...use the full context width && have consistent margins
    child: Container(
      child: body,
      margin: EdgeInsets.all(margin),
    ),
  );
}

//// Shared sub-widgets

// End drawer with just a link to app settings
Drawer settingsDrawer(BuildContext context) {
  late double buttonSpacer = AppUser.prefs[buttonSpacingKey];

  return Drawer(
    backgroundColor: Color(AppUser.prefs[themeColorKey]),
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
                style: getTextStyle(dialogContentStyle),
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
