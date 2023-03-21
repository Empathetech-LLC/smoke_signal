import '../utils/constants.dart';
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
    return ezScaffold(
      context: context,

      title: 'Edit Profile',

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
          ezIconButton(
            action: () {
              editAvatar(context);
              setState(doNothing);
            },
            body: Text('New pic'),
            icon: Icon(PlatformIcons(context).photoCamera),
          ),

          Container(height: buttonSpacer),

          // Display name
          Text(
            AppUser.account.displayName ?? defaultDisplayName,
            style: getTextStyle(titleStyleKey),
          ),
          Container(height: buttonSpacer),

          // Edit name
          ezIconButton(
            action: () {
              editName(context);
              setState(doNothing);
            },
            body: Text('New name'),
            icon: Icon(PlatformIcons(context).edit),
          ),

          Container(height: buttonSpacer),
        ],
        centered: true,
      ),

      // Background image/decoration
      backgroundImage: buildDecoration(AppConfig.prefs[backImageKey]),

      // Fallback background color
      backgroundColor: Color(AppConfig.prefs[backColorKey]),

      // Scaffold config
      scaffoldConfig: MaterialScaffoldData(),
    );
  }
}
