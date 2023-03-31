import 'package:empathetech_ss_api/empathetech_ss_api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettingsScreen> {
  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];
  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);

  @override
  Widget build(BuildContext context) {
    return EZScaffold(
      // Title && theme
      title: 'Edit Profile',
      backgroundImage: buildDecoration(AppConfig.prefs[backImageKey]),
      backgroundColor: Color(AppConfig.prefs[backColorKey]),

      // Body
      body: ezScrollView(
        children: [
          Container(height: buttonSpacer),

          // Profile image
          CircleAvatar(
            foregroundImage:
                CachedNetworkImageProvider(AppUser.account.photoURL ?? defaultAvatarURL),
            minRadius: 100,
            maxRadius: 100,
          ),
          Container(height: buttonSpacer),

          // Edit picture
          EZButton.icon(
            action: () {
              editAvatar(context);
              setState(doNothing);
            },
            message: 'New pic',
            icon: ezIcon(PlatformIcons(context).photoCamera),
          ),

          Container(height: buttonSpacer),

          // Display name
          Text(
            AppUser.account.displayName ?? defaultDisplayName,
            style: getTextStyle(titleStyleKey),
          ),
          Container(height: buttonSpacer),

          // Edit name
          EZButton.icon(
            action: () {
              editName(context);
              setState(doNothing);
            },
            message: 'New name',
            icon: ezIcon(PlatformIcons(context).edit),
          ),

          Container(height: buttonSpacer),
        ],
        centered: true,
      ),
    );
  }
}
