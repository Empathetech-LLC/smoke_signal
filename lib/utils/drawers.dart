import 'utils.dart';
import '../screens/screens.dart';

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
List<Widget> standardDrawerBody({
  required BuildContext context,
  void Function()? onReturn,
}) {
  double buttonSpacer = EzConfig.prefs[buttonSpacingKey];

  return [
    // GoTo settings
    EzButton.icon(
      action: () async {
        dynamic result = await popAndPushScreen(
          context: context,
          screen: AppSettingsScreen(),
        );

        if (result != null && onReturn != null) onReturn();
      },
      icon: EzIcon(PlatformIcons(context).settings),
      message: 'Settings',
    ),
    Container(height: buttonSpacer),

    // Show input rules
    EzButton(
      action: () => openDialog(
        context: context,
        dialog: EzDialog(
          title: EzText.simple(
            'Input rules',
            style: buildTextStyle(styleKey: dialogTitleStyleKey),
          ),
          contents: [
            EzText.simple(
              validatorRule,
              style: buildTextStyle(styleKey: dialogContentStyleKey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      body: EzText.simple('Input rules'),
    ),
    Container(height: buttonSpacer),
  ];
}

/// Custom drawer header for Signal Board
/// Show profile information, GoTo profile settings, and logout
Widget signalDrawerHeader({
  required BuildContext context,
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
          EzText.simple(
            AppUser.account.displayName ?? defaultDisplayName,
            style: buildTextStyle(styleKey: dialogTitleStyleKey),
          ),
        ],
      ),

      // Edit and logout buttons
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Edit
          EzButton(
            action: () async {
              dynamic shouldRefresh = await popAndPushScreen(
                context: context,
                screen: ProfileSettingsScreen(),
              );

              if (shouldRefresh != null) refresh();
            },
            body: EzIcon(PlatformIcons(context).edit),
          ),
          Container(height: EzConfig.prefs[dialogSpacingKey]),

          // Logout
          EzButton(
            action: () => logout(context),
            body: EzIcon(Icons.logout),
          ),
        ],
      ),
    ],
  );
}
