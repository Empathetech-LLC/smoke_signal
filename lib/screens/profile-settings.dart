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
  late Color themeTextColor = Color(EzConfig.prefs[themeTextColorKey]);

  late double buttonSpacer = EzConfig.prefs[buttonSpacingKey];

  late String name = AppUser.account.displayName ?? defaultDisplayName;
  late String url = AppUser.account.photoURL ?? defaultAvatarURL;

  /// Get the display name from source
  void refreshName() async {
    String newName = await getName();

    setState(() {
      name = newName;
    });
  }

  /// Get the pic URL from source
  void refreshPic() async {
    String newUrl = await getAvatar();

    setState(() {
      url = newUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return EzScaffold(
      // Title && theme
      title: Text('Edit Profile', style: getTextStyle(titleStyleKey)),
      backgroundImage: buildDecoration(EzConfig.prefs[backImageKey]),
      backgroundColor: Color(EzConfig.prefs[backColorKey]),

      // Body
      body: ezScrollView(
        children: [
          Container(height: buttonSpacer),

          // Profile image
          CircleAvatar(
            foregroundImage: CachedNetworkImageProvider(url),
            minRadius: 100,
            maxRadius: 100,
          ),
          Container(height: buttonSpacer),

          // Edit picture
          EZButton.icon(
            action: () async {
              bool shouldRefresh = await editAvatar(context);
              if (shouldRefresh) refreshPic();
            },
            message: 'New pic',
            icon: ezIcon(PlatformIcons(context).photoCamera),
          ),

          Container(height: buttonSpacer),

          // Display name
          Text(name, style: getTextStyle(titleStyleKey)),
          Container(height: buttonSpacer),

          // Edit name
          EZButton.icon(
            action: () async {
              bool shouldRefresh = await editName(context);
              if (shouldRefresh) refreshName();
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
