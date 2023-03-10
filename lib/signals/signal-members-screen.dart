import '../signals/signal-api.dart';
import '../utils/custom-widgets.dart';
import '../utils/constants.dart';
import '../utils/scaffolds.dart';
import '../utils/storage.dart';
import '../user/user-api.dart';
import '../utils/text.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SignalMemberScreen extends StatelessWidget {
  const SignalMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gather signal data from navigator arguments
    // There is no path to this route except via a signal
    final args =
        (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

    return SignalMembers(
      title: args[titleArg],
      members: args[membersArg],
      activeMembers: args[activeMembersArg],
      memberReqs: args[memberReqsArg],
    );
  }
}

class SignalMembers extends StatefulWidget {
  const SignalMembers({
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
  _SignalMembersState createState() => _SignalMembersState();
}

class _SignalMembersState extends State<SignalMembers> {
  //// Initialize state

  late Stream<QuerySnapshot<Map<String, dynamic>>> _userStream;

  @override
  void initState() {
    super.initState();
    _userStream = streamUsers();
  }

  late List<String> requestIDs = [];

  // Gather theme data
  late double buttonSpacer = AppUser.prefs[buttonSpacingKey];
  late double dialogSpacer = AppUser.prefs[dialogSpacingKey];

  late Color buttonColor = Color(AppUser.prefs[buttonColorKey]);
  late Color buttonTextColor = Color(AppUser.prefs[buttonTextColorKey]);

  // Creates the widgets for the toggle list from the gathered profiles
  List<Widget> buildSwitches(List<UserProfile> profiles) {
    List<Widget> children = [];

    profiles.forEach((profile) {
      if (profile.id != AppUser.account.uid)
        children.addAll(
          [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Check box
                Checkbox(
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
                  fillColor: MaterialStateProperty.all(buttonColor),
                  checkColor: buttonTextColor,
                  activeColor: buttonColor,
                ),

                // Profile image/avatar
                CircleAvatar(
                  backgroundImage: AssetImage(loadingGifPath),
                  foregroundImage: CachedNetworkImageProvider(profile.avatarURL),
                  minRadius: 35,
                  maxRadius: 35,
                ),

                // Display name
                paddedText(profile.name, dialogTitleStyle, TextAlign.start),
              ],
            ),
            Container(height: dialogSpacer),
          ],
        );
    });

    // Add (send requests) button
    children.addAll(
      [
        ezButton(
          () async {
            await requestMembers(context, widget.title, requestIDs);
            Navigator.of(context).popUntil(ModalRoute.withName(homeRoute));
          },
          () {},
          PlatformText('Send requests'),
        ),
        Container(height: dialogSpacer),
      ],
    );

    return children;
  }

  Widget sortUsers(List<UserProfile> profiles) {
    List<UserProfile> memberProfiles = [];
    List<UserProfile> activeProfiles = [];
    List<UserProfile> pendingProfiles = [];
    List<UserProfile> unnaddedProfiles = [];

    profiles.forEach((profile) {
      if (widget.members.contains(profile.id)) {
        memberProfiles.add(profile);

        if (widget.activeMembers.contains(profile.id)) {
          activeProfiles.add(profile);
        }
      } else if (widget.memberReqs.contains(profile.id)) {
        pendingProfiles.add(profile);
      } else {
        unnaddedProfiles.add(profile);
      }
    });

    return ezScrollView(
      [
        // Available members - show all pictures
        paddedText('Available', titleStyle),
        showUserPics(context, memberProfiles),
        Container(height: buttonSpacer),

        // Active members - show all pictures
        paddedText('Active', titleStyle),
        showUserPics(context, activeProfiles),
        Container(height: buttonSpacer),

        // Pending members - expandable profiles
        ezList('Pending', [showUserProfiles(context, pendingProfiles)]),

        // Addable users - exandable, toggle-able, profiles
        ezList('Add?', buildSwitches(unnaddedProfiles)),
        Container(height: buttonSpacer),
      ],
    );
  }

  //// Draw state

  @override
  Widget build(BuildContext context) {
    return standardScaffold(
      context,

      // Title
      widget.title + ' members',

      // Body
      StreamBuilder<QuerySnapshot>(
        stream: _userStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return loadingMessage(context);
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                return Center(
                  child: PlatformText(
                    snapshot.error.toString(),
                    style: getTextStyle(errorStyle),
                  ),
                );
              }

              return sortUsers(buildProfiles(snapshot.data!.docs));
          }
        },
      ),

      // Background image/decoration
      buildDecoration(AppUser.prefs[backImageKey]),

      // Fallback background color
      Color(AppUser.prefs[signalsBackgroundColorKey]),

      // Drawer aka settings hamburger
      null,
    );
  }
}
