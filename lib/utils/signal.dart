import 'utils.dart';
import '../screens/screens.dart';

import 'package:empathetech_ss_api/empathetech_ss_api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Happy signaling!
class Signal extends StatefulWidget {
  const Signal({
    Key? key,
    required this.title,
    required this.message,
    required this.members,
    required this.owner,
    required this.activeMembers,
    required this.memberReqs,
    required this.reloadBoard,
  }) : super(key: key);

  final String title;
  final String message;
  final List<String> members;
  final String owner;
  final List<String> activeMembers;
  final List<String> memberReqs;

  final void Function() reloadBoard;

  /// Construct a [Signal] from a Firebase signal [DocumentSnapshot]
  static Signal buildSignal(
    DocumentSnapshot signalDoc,
    void Function() reloadBoard,
  ) {
    final data = signalDoc.data() as Map<String, dynamic>;

    return Signal(
      title: signalDoc.id,
      message: data[messagePath],
      members: List<String>.from(data[membersPath]),
      owner: data[ownerPath],
      activeMembers: List<String>.from(data[activeMembersPath]),
      memberReqs: List<String>.from(data[memberReqsPath]),
      reloadBoard: reloadBoard,
    );
  }

  @override
  _SignalState createState() => _SignalState();
}

class _SignalState extends State<Signal> {
  late String signalTitle = widget.title;
  late String showIconKey = signalTitle + 'ShowIcon';
  late String iconPathKey = signalTitle + 'Icon';

  late bool showIcon = AppConfig.preferences.getBool(showIconKey) ?? false;

  late Color themeColor = Color(AppConfig.prefs[themeColorKey]);
  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);
  late Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);
  late Color buttonTextColor = Color(AppConfig.prefs[buttonTextColorKey]);
  late Color joinedColor = Color(AppConfig.prefs[joinedColorKey]);
  late Color joinedTextColor = Color(AppConfig.prefs[joinedTextColorKey]);
  late Color watchingColor = Color(AppConfig.prefs[watchingColorKey]);
  late Color watchingTextColor = Color(AppConfig.prefs[watchingTextColorKey]);

  late double dialogSpacer = AppConfig.prefs[dialogSpacingKey];
  late double signalSpacer = AppConfig.prefs[signalSpacingKey];
  late double signalHeight = AppConfig.prefs[signalHeightKey];
  late double signalCountHeight = AppConfig.prefs[signalCountHeightKey];

  late TextStyle titleTextStyle = getTextStyle(titleStyleKey);
  late TextStyle buttonTextStyle = getTextStyle(buttonStyleKey);

  late TextStyle joinedTextStyle = TextStyle(
    fontFamily: titleTextStyle.fontFamily,
    fontSize: titleTextStyle.fontSize,
    color: joinedTextColor,
  );

  late TextStyle watchingTextStyle = TextStyle(
    fontFamily: titleTextStyle.fontFamily,
    fontSize: titleTextStyle.fontSize,
    color: watchingTextColor,
  );

  /// Set a custom [Icon] for the [Signal] via [changeImage]
  /// Returns the path of the new image on success
  Future<dynamic> setIcon() {
    return ezDialog(
      context,
      title: 'From where?',
      content: [
        // From file
        EZButton.icon(
          action: () async {
            String? changed = await changeImage(
              context,
              prefsPath: iconPathKey,
              source: ImageSource.gallery,
            );

            popScreen(context, pass: changed);
          },
          message: 'File',
          icon: ezIcon(PlatformIcons(context).folder),
        ),
        Container(height: dialogSpacer),

        // From camera
        EZButton.icon(
          action: () async {
            String? changed = await changeImage(
              context,
              prefsPath: iconPathKey,
              source: ImageSource.camera,
            );
            popScreen(context, pass: changed);
          },
          message: 'Camera',
          icon: ezIcon(PlatformIcons(context).photoCamera),
        ),
        Container(height: dialogSpacer),

        // Reset
        EZButton.icon(
          action: () async {
            // Build path
            Directory currDir = await getApplicationDocumentsDirectory();
            String imagePath = currDir.path + signalTitle;

            // Delete any saved files
            try {
              File toDelete = File(imagePath);
              await toDelete.delete();
            } catch (e) {
              doNothing();
              // Delete is called without knowledge of a file existing, so ignore errors
            }

            // Wipe [SharedPreferences]
            AppConfig.preferences.remove(iconPathKey);
            popScreen(context, pass: true);
          },
          message: 'Reset',
          icon: ezIcon(PlatformIcons(context).refresh),
        ),
      ],
    );
  }

  /// Toggle whether the [Signal]s icon ([Image]) is being shown
  void toggleIcon() {
    // Hide icon
    if (showIcon) {
      AppConfig.preferences.remove(showIconKey);
      setState(() {
        showIcon = false;
      });
    }

    // Show icon
    else {
      AppConfig.preferences.setBool(showIconKey, true);
      setState(() {
        showIcon = true;
      });
    }
  }

  /// Show all [Signal] edits the user can make
  Future<dynamic> showEdits() {
    return ezDialog(
      context,
      title: 'Options',
      content: [
        // Manage members
        EZButton(
          action: () => popAndPushScreen(
            context,
            screen: SignalMembersScreen(
              title: signalTitle,
              members: widget.members,
              activeMembers: widget.activeMembers,
              memberReqs: widget.memberReqs,
            ),
          ),
          body: Text('Members'),
        ),
        Container(height: dialogSpacer),

        // Set icon
        EZButton(
          action: () async {
            dynamic result = await setIcon();
            popScreen(context, pass: result);
            if (result != null) widget.reloadBoard();
          },
          body: Text('Set icon'),
        ),
        Container(height: dialogSpacer),

        // Show/hide icon
        EZButton(action: toggleIcon, body: Text('Toggle icon')),
        Container(height: dialogSpacer),

        // Owner: Reset count, update message, transfer signal, or delete signal
        // Member: Leave signal
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: AppUser.account.uid == widget.owner
              ? [
                  // Reset
                  EZButton(
                    action: () async {
                      popScreen(context, pass: true);
                      await resetSignal(context, signalTitle);
                      // Reset signal triggers a stream update
                      // so the screen will update automatically
                    },
                    body: Text('Reset signal'),
                  ),
                  Container(height: dialogSpacer),

                  // Update message
                  EZButton(
                    action: () async {
                      dynamic result = await updateMessage(context, signalTitle);
                      popScreen(context, pass: result);
                    },
                    body: Text('Update message'),
                  ),
                  Container(height: dialogSpacer),

                  // Transfer
                  EZButton(
                    action: () async {
                      dynamic result =
                          await confirmTransfer(context, signalTitle, widget.members);
                      popScreen(context, pass: result);
                    },
                    body: Text('Transfer signal'),
                  ),
                  Container(height: dialogSpacer),

                  // Delete
                  EZButton(
                    action: () {
                      popScreen(context);
                      confirmDelete(
                        context,
                        signalTitle,
                        [showIconKey, iconPathKey],
                      );
                      // Deleting a signal triggers a stream update
                      // so the screen will update automatically
                    },
                    body: Text('Delete signal'),
                  ),
                ]
              : [
                  // Leave
                  EZButton(
                    action: () {
                      popScreen(context);
                      confirmDeparture(
                        context,
                        signalTitle,
                        [showIconKey, iconPathKey],
                      );
                      // Leaving a signal triggers a stream update
                      // so the screen will update automatically
                    },
                    body: Text('Leave signal'),
                  ),
                ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double padding = AppConfig.prefs[paddingKey];

    // Current user is a member
    if (widget.members.contains(AppUser.account.uid)) {
      bool joined = widget.activeMembers.contains(AppUser.account.uid);

      return Column(
        children: [
          // Signal button
          showIcon
              // With icon image
              ? GestureDetector(
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
                        // Icon image
                        Container(
                          width: signalHeight,
                          height: signalHeight,
                          child: ezImage(
                            pathKey: iconPathKey,
                            backup: appIconPath,
                          ),
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
                )
              : GestureDetector(
                  onTap: () => toggleParticipation(
                    context,
                    joined,
                    widget.title,
                    widget.members,
                    widget.message,
                  ),
                  onLongPress: showEdits,
                  child: SizedBox(
                    width: screenWidth(context),
                    height: signalHeight,
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

          // Signal count
          SizedBox(
            width: screenWidth(context) * (2 / 3),
            height: signalCountHeight,
            child: Card(
              color: widget.activeMembers.contains(AppUser.account.uid)
                  ? joinedColor
                  : watchingColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                // Check AppUser's current participation
                children: widget.activeMembers.contains(AppUser.account.uid)
                    ? [
                        // Active: show the current count surrounded by smoke signals
                        ezImage(pathKey: signalImageKey),
                        Text(
                          widget.activeMembers.length.toString(),
                          style: joinedTextStyle,
                        ),
                        ezImage(pathKey: signalImageKey),
                      ]
                    : [
                        // Inactive: only show the current count
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
          SizedBox(
            width: screenWidth(context),
            height: signalHeight,
            child: Card(
              color: watchingColor,
              child: Center(
                child: Text(
                  'Join:\n$signalTitle?',
                  style: watchingTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(height: padding),

          // Buttons
          ezYesNo(
            context,
            onConfirm: () async {
              await acceptInvite(context, signalTitle);
            },
            onDeny: () async {
              await declineInvite(context, signalTitle);
            },
            axis: Axis.horizontal,
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
