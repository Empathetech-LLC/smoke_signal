import '../utils/utils.dart';

import 'package:empathetech_ss_api/empathetech_ss_api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SignalMembersScreen extends StatefulWidget {
  const SignalMembersScreen({
    Key? key,
    required this.title,
    required this.members,
    required this.activeMembers,
    required this.memberReqs,
  }) : super(key: key);

  final String title;
  final List<String> members;
  final List<String> activeMembers;
  final List<String> memberReqs;

  @override
  _SignalMembersScreenState createState() => _SignalMembersScreenState();
}

class _SignalMembersScreenState extends State<SignalMembersScreen> {
  // Initialize state

  late Stream<QuerySnapshot<Map<String, dynamic>>> _userStream;

  @override
  void initState() {
    super.initState();
    _userStream = streamUsers();
  }

  late List<String> requestIDs = [];

  // Gather theme data
  late double buttonSpacer = EzConfig.prefs[buttonSpacingKey];
  late double dialogSpacer = EzConfig.prefs[dialogSpacingKey];

  late Color themeColor = Color(EzConfig.prefs[themeColorKey]);
  late Color buttonColor = Color(EzConfig.prefs[buttonColorKey]);
  late Color buttonTextColor = Color(EzConfig.prefs[buttonTextColorKey]);

  // Creates the widgets for the toggle list from the gathered profiles
  List<PlatformListTile> buildSwitchTiles(List<UserProfile> profiles) {
    List<PlatformListTile> children = [];

    profiles.forEach((profile) {
      if (profile.id != AppUser.account.uid)
        children.add(
          PlatformListTile(
            // User info
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile image/avatar
                CircleAvatar(
                  foregroundImage: CachedNetworkImageProvider(profile.avatarURL),
                  minRadius: 35,
                  maxRadius: 35,
                ),
                Container(width: EzConfig.prefs[paddingKey]),

                // Display name
                ezText(
                  profile.name,
                  style: getTextStyle(dialogTitleStyleKey),
                  textAlign: TextAlign.start,
                ),
              ],
            ),

            // Toggle
            trailing: ezCheckBox(
              value: requestIDs.contains(profile.id),
              onChanged: (bool? value) {
                if (value == true) {
                  setState(() {
                    requestIDs.add(profile.id);
                  });
                } else {
                  setState(() {
                    requestIDs.remove(profile.id);
                  });
                }
              },
            ),
          ),
        );
    });

    return children;
  }

  Widget sortUsers(List<UserProfile> profiles) {
    List<UserProfile> memberProfiles = [];
    List<UserProfile> activeProfiles = [];
    List<UserProfile> pendingProfiles = [];
    List<UserProfile> unAddedProfiles = [];

    profiles.forEach((profile) {
      if (widget.members.contains(profile.id)) {
        memberProfiles.add(profile);

        if (widget.activeMembers.contains(profile.id)) {
          activeProfiles.add(profile);
        }
      } else if (widget.memberReqs.contains(profile.id)) {
        pendingProfiles.add(profile);
      } else {
        unAddedProfiles.add(profile);
      }
    });

    List<Widget> viewChildren = [
      // Available members - show all pictures
      ezText(
        'Available',
        style: getTextStyle(titleStyleKey),
        background: Color(EzConfig.prefs[themeColorKey]),
      ),
      showUserPics(context, memberProfiles),
      Container(height: buttonSpacer),

      // Active members - show all pictures
      ezText(
        'Active',
        style: getTextStyle(titleStyleKey),
        background: Color(EzConfig.prefs[themeColorKey]),
      ),
      showUserPics(context, activeProfiles),
      Container(height: buttonSpacer),
    ];

    if (unAddedProfiles.isNotEmpty) {
      // Addable users - expandable, toggle-able, profiles
      viewChildren.addAll(
        [
          ezTileList(
            context: context,
            title: 'Add?',
            items: buildSwitchTiles(unAddedProfiles),
          ),
          Container(height: buttonSpacer),

          // Submit button
          EZButton.icon(
            action: () async {
              await requestMembers(context, widget.title, requestIDs);
              popScreen(context: context, pass: true);
            },
            message: 'Send requests',
            icon: ezIcon(PlatformIcons(context).cloudUpload),
          ),
        ],
      );
    }

    return ezScrollView(children: viewChildren);
  }

  // Draw state

  @override
  Widget build(BuildContext context) {
    return EzScaffold(
      background: BoxDecoration(color: Color(EzConfig.prefs[backColorKey])),
      appBar: EzAppBar(
        title: Text(widget.title + ' members', style: getTextStyle(titleStyleKey)),
      ),

      // Body
      body: standardWindow(
        context: context,
        background: imageBackground(EzConfig.prefs[backImageKey]),
        body: StreamBuilder<QuerySnapshot>(
          stream: _userStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return loadingMessage(
                  context: context,
                  image: ezImage(pathKey: signalImageKey),
                );
              case ConnectionState.done:
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: getTextStyle(errorStyleKey),
                    ),
                  );
                }

                return sortUsers(buildProfiles(snapshot.data!.docs));
            }
          },
        ),
      ),
    );
  }
}
