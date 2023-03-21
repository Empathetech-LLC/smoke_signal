import '../user/user-api.dart';
import '../signals/signal-api.dart';
import '../utils/constants.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

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
  // Initialize state

  late String signalTitle = widget.title;

  late String showIconPref = signalTitle + 'ShowIcon';
  late String iconPathPref = signalTitle + 'Icon';

  late bool showIcon = AppConfig.preferences.getBool(showIconPref) ?? false;
  late String iconPath = AppConfig.preferences.getString(iconPathPref) ?? appIconPath;

  // Gather theme data
  late double dialogSpacer = AppConfig.prefs[dialogSpacingKey];
  late double signalSpacer = AppConfig.prefs[signalSpacingKey];

  late double signalHeight = AppConfig.prefs[signalHeightKey];
  late double signalCountHeight = AppConfig.prefs[signalCountHeightKey];

  late Color themeColor = Color(AppConfig.prefs[themeColorKey]);
  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);

  late Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);
  late Color buttonTextColor = Color(AppConfig.prefs[buttonTextColorKey]);

  late Color joinedColor = Color(AppConfig.prefs[joinedColorKey]);
  late Color joinedTextColor = Color(AppConfig.prefs[joinedTextColorKey]);

  late Color watchingColor = Color(AppConfig.prefs[watchingColorKey]);
  late Color watchingTextColor = Color(AppConfig.prefs[watchingTextColorKey]);

  late TextStyle buttonTextStyle = getTextStyle(buttonStyleKey);
  late TextStyle titleTextStyle = getTextStyle(titleStyleKey);

  late TextStyle joinedTextStyle = TextStyle(
    fontFamily: titleTextStyle.fontFamily,
    fontSize: titleTextStyle.fontSize,
    color: Color(AppConfig.prefs[joinedTextColorKey]),
  );

  late TextStyle watchingTextStyle = TextStyle(
    fontFamily: titleTextStyle.fontFamily,
    fontSize: titleTextStyle.fontSize,
    color: Color(AppConfig.prefs[watchingTextColorKey]),
  );

  // Define interactions

  // Set a custom icon for the signal
  void setIcon() {
    ezDialog(
      context: context,
      title: 'From where?',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // From file
          ezIconButton(
            action: () {
              changeImage(
                context: context,
                prefsPath: iconPathPref,
                source: ImageSource.gallery,
              );
              Navigator.of(context).pop();
            },
            body: Text('File'),
            icon: Icon(PlatformIcons(context).folder),
          ),
          Container(height: dialogSpacer),

          // From camera
          ezIconButton(
            action: () {
              changeImage(
                context: context,
                prefsPath: iconPathPref,
                source: ImageSource.camera,
              );
              Navigator.of(context).pop();
            },
            body: Text('Camera'),
            icon: Icon(PlatformIcons(context).photoCamera),
          ),
          Container(height: dialogSpacer),

          // Reset
          ezButton(
            action: () async {
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
              AppConfig.preferences.remove(iconPathPref);
              Navigator.of(context).pop();
            },
            body: Text('Reset'),
          ),
          Container(height: dialogSpacer),
        ],
      ),
    );
  }

  // Flip the state of whether the Signal's icon show be displayed
  void toggleIcon() {
    // Hide icon
    if (showIcon) {
      AppConfig.preferences.remove(showIconPref);
      setState(() {
        showIcon = false;
      });
    }

    // Show icon
    else {
      AppConfig.preferences.setBool(showIconPref, true);
      setState(() {
        showIcon = true;
      });
    }
  }

  // Show all edits the user can make
  void showEdits() {
    ezDialog(
      context: context,
      title: 'Options',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Manage members
          ezButton(
            action: () => Navigator.of(context).popAndPushNamed(
              signalMembersRoute,
              arguments: {
                titleArg: signalTitle,
                membersArg: widget.members,
                activeMembersArg: widget.activeMembers,
                memberReqsArg: widget.memberReqs,
              },
            ),
            body: Text('Members'),
          ),
          Container(height: dialogSpacer),

          // Set icon
          ezButton(action: setIcon, body: Text('Set icon')),
          Container(height: dialogSpacer),

          // Show/hide icon
          ezButton(action: toggleIcon, body: Text('Toggle icon')),
          Container(height: dialogSpacer),

          // Owner: Reset count, update message, transfer signal, or delete signal
          // Member: Leave signal
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: AppUser.account.uid == widget.owner
                ? [
                    ezButton(
                      action: () async {
                        Navigator.of(context).pop();
                        await resetSignal(context, signalTitle);
                      },
                      body: Text('Reset signal'),
                    ),
                    Container(height: dialogSpacer),
                    ezButton(
                      action: () {
                        Navigator.of(context).pop();
                        updateMessage(context, signalTitle);
                      },
                      body: Text('Update message'),
                    ),
                    Container(height: dialogSpacer),
                    ezButton(
                      action: () {
                        Navigator.of(context).pop();
                        confirmTransfer(context, signalTitle, widget.members);
                      },
                      body: Text('Transfer signal'),
                    ),
                    Container(height: dialogSpacer),
                    ezButton(
                      action: () {
                        Navigator.of(context).pop();
                        confirmDelete(
                          context,
                          signalTitle,
                          [showIconPref, iconPathPref],
                        );
                      },
                      body: Text('Delete signal'),
                    ),
                    Container(height: dialogSpacer),
                  ]
                : [
                    ezButton(
                      action: () {
                        Navigator.of(context).pop();
                        confirmDeparture(
                          context,
                          signalTitle,
                          [showIconPref, iconPathPref],
                        );
                      },
                      body: Text('Leave signal'),
                    ),
                    Container(height: dialogSpacer),
                  ],
          ),
        ],
      ),
    );
  }

  // Draw state

  // Signal button styling
  ButtonStyle signalStyle() {
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

  // Default (no icon) signal styling
  Widget defaultSignal() {
    bool joined = widget.activeMembers.contains(AppUser.account.uid);

    return ezButton(
      action: () => toggleParticipation(
        context,
        joined,
        widget.title,
        widget.members,
        widget.message,
      ),
      longAction: showEdits,
      body: Text(
        signalTitle,
        style: joined ? joinedTextStyle : watchingTextStyle,
      ),
      customStyle: signalStyle(),
    );
  }

  // Signal styling when the icon is showing
  Widget iconSignal() {
    bool joined = widget.activeMembers.contains(AppUser.account.uid);

    return GestureDetector(
      onTap: () => toggleParticipation(
        context,
        joined,
        widget.title,
        widget.members,
        widget.message,
      ),
      onLongPress: showEdits,
      child: Container(
        width: screenWidth(context),
        height: signalHeight,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Icon
            Container(
              width: signalHeight,
              child: Card(
                  child: buildImage(
                path: iconPath,
              )),
            ),

            // Title card
            Expanded(
              child: SizedBox.expand(
                child: Card(
                  color: joined ? joinedColor : watchingColor,
                  child: Center(
                    child: Text(
                      signalTitle,
                      style: joined ? joinedTextStyle : watchingTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
                        buildImage(
                          path: AppConfig.prefs[signalImageKey],
                        ),
                        Text(
                          widget.activeMembers.length.toString(),
                          style: joinedTextStyle,
                        ),
                        buildImage(
                          path: AppConfig.prefs[signalImageKey],
                        ),
                      ]
                    : [
                        // Only show the current count
                        Text(
                          widget.activeMembers.length.toString(),
                          style: watchingTextStyle,
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
            action: doNothing,
            body: Text('Join:\n$signalTitle?', style: watchingTextStyle),
            customStyle: signalStyle(),
          ),

          // Buttons
          SizedBox(
            width: screenWidth(context) * (2 / 3),
            height: signalCountHeight,
            child: ezYesNo(
              context: context,
              onConfirm: () async {
                await acceptInvite(context, signalTitle);
                setState(doNothing);
              },
              onDeny: () async {
                await declineInvite(context, signalTitle);
                setState(doNothing);
              },
              axis: Axis.horizontal,
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
