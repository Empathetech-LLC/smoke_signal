import '../utils/custom-widgets.dart';
import '../user/user-api.dart';
import '../signals/signal-api.dart';
import '../utils/constants.dart';
import '../utils/storage.dart';
import '../utils/text.dart';
import '../utils/helpers.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class Signal extends StatefulWidget {
  const Signal({
    Key? key,
    required this.title,
    required this.message,
    required this.members,
    required this.owner,
    required this.activeMembers,
    required this.memberReqs,
  }) : super(key: key);

  final String title;
  final String message;
  final List<String> members;
  final String owner;
  final List<String> activeMembers;
  final List<String> memberReqs;

  // Local signal constructor from signal db document
  static Signal buildSignal(DocumentSnapshot signalDoc) {
    final data = signalDoc.data() as Map<String, dynamic>;

    return Signal(
      title: signalDoc.id,
      message: data[messagePath],
      members: List<String>.from(data[membersPath]),
      owner: data[ownerPath],
      activeMembers: List<String>.from(data[activeMembersPath]),
      memberReqs: List<String>.from(data[memberReqsPath]),
    );
  }

  @override
  _SignalState createState() => _SignalState();
}

class _SignalState extends State<Signal> {
  //// Initialize state

  late String signalTitle = widget.title;

  late String showIconPref = signalTitle + 'ShowIcon';
  late String iconPathPref = signalTitle + 'Icon';

  late bool showIcon = AppUser.preferences.getBool(showIconPref) ?? false;
  late String iconPath = AppUser.preferences.getString(iconPathPref) ?? appIconPath;

  // Gather theme data
  late double dialogSpacer = AppUser.prefs[dialogSpacingKey];
  late double signalSpacer = AppUser.prefs[signalSpacingKey];

  late double signalHeight = AppUser.prefs[signalHeightKey];
  late double signalCountHeight = AppUser.prefs[signalCountHeightKey];

  late Color themeColor = Color(AppUser.prefs[themeColorKey]);
  late Color themeTextColor = Color(AppUser.prefs[themeTextColorKey]);

  late Color buttonColor = Color(AppUser.prefs[buttonColorKey]);
  late Color buttonTextColor = Color(AppUser.prefs[buttonTextColorKey]);

  late Color joinedColor = Color(AppUser.prefs[joinedColorKey]);
  late Color joinedTextColor = Color(AppUser.prefs[joinedTextColorKey]);

  late Color watchingColor = Color(AppUser.prefs[watchingColorKey]);
  late Color watchingTextColor = Color(AppUser.prefs[watchingTextColorKey]);

  //// Interaction methods

  // Set a custom icon for the signal
  void setIcon() {
    ezDialog(
      context,

      // Title
      'From where?',

      // Body
      [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // From file
            ezIconButton(
              () {
                changeImage(context, iconPathPref, ImageSource.gallery);
                Navigator.of(context).pop();
              },
              () {},
              Icon(Icons.file_open),
              PlatformText('File'),
            ),
            Container(height: dialogSpacer),

            // From camera
            ezIconButton(
              () {
                changeImage(context, iconPathPref, ImageSource.camera);
                Navigator.of(context).pop();
              },
              () {},
              Icon(Icons.camera_alt),
              PlatformText('Camera'),
            ),
            Container(height: dialogSpacer),

            // Reset
            ezButton(
              () async {
                // Build path
                Directory currDir = await getApplicationDocumentsDirectory();
                String imagePath = currDir.path + signalTitle;

                // Delete any saved files
                try {
                  File toDelete = File(imagePath);
                  await toDelete.delete();
                } catch (e) {
                  // Ignore errors thrown
                  // Delete is called without knowledge of a file existing
                }

                // Wipe the shared pref
                AppUser.preferences.remove(iconPathPref);
                Navigator.of(context).pop();
              },
              () {},
              PlatformText('Reset'),
            ),
            Container(height: dialogSpacer),
          ],
        )
      ],
    );
  }

  // Flip the state of whether the Signal's icon show be displayed
  void toggleIcon() {
    // Hide icon
    if (showIcon) {
      AppUser.preferences.remove(showIconPref);
      setState(() {
        showIcon = false;
      });
    }

    // Show icon
    else {
      AppUser.preferences.setBool(showIconPref, true);
      setState(() {
        showIcon = true;
      });
    }
  }

  // Show all edits the user can make
  void showEdits() {
    ezDialog(
      context,

      // Title
      'Options',

      // Body
      [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Manage members
            ezButton(
              () => Navigator.of(context).popAndPushNamed(
                signalMembersRoute,
                arguments: {
                  titleArg: signalTitle,
                  membersArg: widget.members,
                  activeMembersArg: widget.activeMembers,
                  memberReqsArg: widget.memberReqs,
                },
              ),
              () {},
              PlatformText('Members'),
            ),
            Container(height: dialogSpacer),

            // Set icon
            ezButton(setIcon, () {}, PlatformText('Set icon')),
            Container(height: dialogSpacer),

            // Show/hide icon
            ezButton(toggleIcon, () {}, PlatformText('Toggle icon')),
            Container(height: dialogSpacer),

            // Owner: Reset count, update message, transfer signal, or delete signal
            // Member: Leave signal
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: AppUser.account.uid == widget.owner
                  ? [
                      ezButton(
                        () async {
                          await resetSignal(context, signalTitle);
                          Navigator.of(context).pop();
                        },
                        () {},
                        PlatformText('Reset signal'),
                      ),
                      Container(height: dialogSpacer),
                      ezButton(
                        () => updateMessage(context, signalTitle),
                        () {},
                        PlatformText('Update message'),
                      ),
                      Container(height: dialogSpacer),
                      ezButton(
                        () => confirmTransfer(
                          context,
                          signalTitle,
                          widget.members,
                        ),
                        () {},
                        PlatformText('Transfer signal'),
                      ),
                      Container(height: dialogSpacer),
                      ezButton(
                        () => confirmDelete(
                          context,
                          signalTitle,
                          [showIconPref, iconPathPref],
                        ),
                        () {},
                        PlatformText('Delete signal'),
                      ),
                      Container(height: dialogSpacer),
                    ]
                  : [
                      ezButton(
                        () => confirmDeparture(
                          context,
                          signalTitle,
                          [showIconPref, iconPathPref],
                        ),
                        () {},
                        PlatformText('Leave signal'),
                      ),
                      Container(height: dialogSpacer),
                    ],
            ),
          ],
        ),
      ],
    );
  }

  //// Draw state

  // Default (no icon) signal styling
  ButtonStyle defaultStyle() {
    bool joined = widget.activeMembers.contains(AppUser.account.uid);

    return joined
        ? ElevatedButton.styleFrom(
            backgroundColor: joinedColor,
            shadowColor: joinedColor,
            foregroundColor: joinedColor,
            fixedSize: Size(screenWidth(context), signalHeight),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: watchingColor,
            shadowColor: watchingColor,
            foregroundColor: watchingColor,
            fixedSize: Size(screenWidth(context), signalHeight),
          );
  }

  // Signal styling when the icon is showing
  ButtonStyle iconStyle() {
    bool joined = widget.activeMembers.contains(AppUser.account.uid);

    return joined
        ? ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: joinedColor,
            fixedSize: Size(screenWidth(context), signalHeight),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: watchingColor,
            fixedSize: Size(screenWidth(context), signalHeight),
          );
  }

  // Default (no icon) signal styling
  Widget defaultSignal() {
    bool joined = widget.activeMembers.contains(AppUser.account.uid);

    return ezButton(
      () => toggleParticipation(
        context,
        joined,
        widget.title,
        widget.members,
        widget.message,
      ),
      showEdits,
      PlatformText(
        signalTitle,
        style: joined ? getTextStyle(joinedStyle) : getTextStyle(watchingStyle),
        textAlign: TextAlign.center,
      ),
      defaultStyle(),
    );
  }

  // Signal styling when the icon is showing
  Widget iconSignal() {
    bool joined = widget.activeMembers.contains(AppUser.account.uid);

    return ezButton(
      () => toggleParticipation(
        context,
        joined,
        widget.title,
        widget.members,
        widget.message,
      ),
      showEdits,
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Icon
          Container(
            width: signalHeight,
            height: signalHeight,
            child: Card(child: buildImage(iconPath)),
          ),

          // Title card
          Expanded(
            child: SizedBox.expand(
              child: Card(
                color: joined ? joinedColor : watchingColor,
                child: Center(
                  child: PlatformText(
                    signalTitle,
                    style:
                        joined ? getTextStyle(joinedStyle) : getTextStyle(watchingStyle),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      iconStyle(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current user is a member
    if (widget.members.contains(AppUser.account.uid)) {
      return Column(
        children: [
          // Signal button
          showIcon ? iconSignal() : defaultSignal(),

          // Signal count
          SizedBox(
            // Show current count
            width: screenWidth(context) * (2 / 3),
            height: signalCountHeight,
            child: Card(
              color: widget.activeMembers.contains(AppUser.account.uid)
                  ? joinedColor
                  : watchingColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: widget.activeMembers.contains(AppUser.account.uid)
                    ? [
                        // Show the current count surrounded by smoke signals
                        buildImage(smokeSignalPath),
                        PlatformText(
                          widget.activeMembers.length.toString(),
                          style: getTextStyle(joinedStyle),
                        ),
                        buildImage(smokeSignalPath),
                      ]
                    : [
                        // Only show the current count
                        PlatformText(
                          widget.activeMembers.length.toString(),
                          style: getTextStyle(watchingStyle),
                        ),
                      ],
              ),
            ),
          ),

          // Bottom spacer for list building
          Container(height: signalSpacer),
        ],
      );

      // Current user is a prospective/requested member
    } else if (widget.memberReqs.contains(AppUser.account.uid)) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Label
          ezButton(
            () {},
            () {},
            PlatformText(
              'Join:\n$signalTitle?',
              style: getTextStyle(watchingStyle),
              textAlign: TextAlign.center,
            ),
            defaultStyle(),
          ),

          // Buttons
          SizedBox(
            width: screenWidth(context) * (2 / 3),
            height: signalCountHeight,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Yes
                ezIconButton(
                  () async {
                    await acceptInvite(context, signalTitle);
                    setState(() {});
                  },
                  () {},
                  Icon(Icons.check),
                  PlatformText('Yes'),
                ),

                // No
                ezIconButton(
                  () async {
                    await declineInvite(context, signalTitle);
                    setState(() {});
                  },
                  () {},
                  Icon(Icons.cancel),
                  PlatformText('No'),
                ),
              ],
            ),
          ),
        ],
      );

      // Default, only reachable if signal stream is unfiltered...
      // ...and the current user is not a member
    } else {
      return Container();
    }
  }
}
