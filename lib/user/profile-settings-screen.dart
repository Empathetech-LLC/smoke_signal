import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../user/user-api.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  // Gather theme data
  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];
  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);

  @override
  Widget build(BuildContext context) {
    return standardScaffold(
      context,

      // Title
      'Edit Profile',

      // Body
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(height: buttonSpacer),

            // Profile image
            CircleAvatar(
              foregroundImage: CachedNetworkImageProvider(
                  AppUser.account.photoURL ?? defaultAvatarURL),
              minRadius: 100,
              maxRadius: 100,
            ),
            Container(height: buttonSpacer),

            // Edit picture
            ezIconButton(
              () {
                editAvatar(context);
                setState(() {});
              },
              () {},
              Icon(Icons.camera),
              Icon(Icons.camera),
              PlatformText('New pic'),
            ),

            Container(height: 1.5 * buttonSpacer),

            // Display name
            PlatformText(
              AppUser.account.displayName ?? defaultDisplayName,
              style: getTextStyle(titleStyleKey),
            ),
            Container(height: buttonSpacer),

            // Edit name
            ezIconButton(
              () {
                editName(context);
                setState(() {});
              },
              () {},
              Icon(Icons.draw),
              Icon(Icons.draw),
              PlatformText('New name'),
            ),

            Container(height: buttonSpacer),
          ],
        ),
      ),

      // Background image/decoration
      buildDecoration(AppConfig.prefs[backImageKey]),

      // Fallback background color
      Color(AppConfig.prefs[backColorKey]),

      // Android drawer aka settings hamburger
      null,

      // iOS nav (top) bar
      null,
    );
  }
}
