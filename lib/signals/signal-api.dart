import '../utils/helpers.dart';
import '../utils/constants.dart';
import '../utils/validate.dart';
import '../user/user-api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Return documents from the 'signals' collection
/// Filter by the current user's membership in the passed field
/// This can cost money!
/// Writing data free tier == 20k writes/day, 1GB limit
/// Reading data free tier == 50k reads/day
Stream<QuerySnapshot<Object?>> streamSignals(String filter) {
  try {
    return AppUser.db
        .collection(signalsPath)
        .where(filter, arrayContains: AppUser.account.uid)
        .snapshots();
  } catch (e) {
    return Stream.empty();
  }
}

// Send new signal to firestore
Future<void> addtoDB(BuildContext context, String title, String message, bool isActive,
    List<String> requestIDs) async {
  try {
    // Check to see if a document with the same name exists
    final check = await AppUser.db.collection(signalsPath).doc(title).get();

    if (check.exists) {
      popNLog(context, 'That name is taken!');
      return;
    }

    // Upload the new document
    await AppUser.db.collection(signalsPath).doc(title).set(
      {
        messagePath: message,
        membersPath: [AppUser.account.uid],
        ownerPath: AppUser.account.uid,
        activeMembersPath: isActive ? [AppUser.account.uid] : [],
        memberReqsPath: requestIDs,
      },
    );
  } catch (e) {
    popNLog(context, e.toString());
  }
}

// Add/remove the current user from the signals list of participants
// Notify other signal members whenever someone joins
Future<void> toggleParticipation(BuildContext context, bool joined, String title,
    List<String> memberIDs, String message) async {
  try {
    if (joined) {
      await AppUser.db.collection(signalsPath).doc(title).update(
        {
          activeMembersPath: FieldValue.arrayRemove([AppUser.account.uid])
        },
      );
    } else {
      await AppUser.db.collection(signalsPath).doc(title).update(
        {
          activeMembersPath: FieldValue.arrayUnion([AppUser.account.uid])
        },
      );

      // Notify members (if there's anyone to notify)
      List<String> others = new List.from(memberIDs);
      others.remove(AppUser.account.uid);

      if (others.isNotEmpty) {
        List<String> tokens = await gatherTokens(others);
        if (tokens.isEmpty) return;

        try {
          await FirebaseFunctions.instance.httpsCallable(sendPushFunc).call({
            tokenData: tokens,
            titleData: title,
            bodyData: message,
          });
        } on FirebaseFunctionsException catch (e) {
          popNLog(context, e.toString());
        }
      }
    }
  } catch (e) {
    popNLog(context, e.toString());
  }
}

// Adds the list of users to the signals member requests
Future<void> requestMembers(
    BuildContext context, String title, List<String> toAdd) async {
  try {
    await AppUser.db.collection(signalsPath).doc(title).update(
      {
        memberReqsPath: FieldValue.arrayUnion(toAdd),
      },
    );
  } catch (e) {
    popNLog(context, e.toString());
  }
}

// Accept joining the passed signal
Future<void> acceptInvite(BuildContext context, String title) async {
  try {
    await AppUser.db.collection(signalsPath).doc(title).update(
      {
        membersPath: FieldValue.arrayUnion([AppUser.account.uid]),
        memberReqsPath: FieldValue.arrayRemove([AppUser.account.uid]),
      },
    );
  } catch (e) {
    popNLog(context, e.toString());
  }
}

// Decline joining the passed signal
Future<void> declineInvite(BuildContext context, String title) async {
  try {
    await AppUser.db.collection(signalsPath).doc(title).update(
      {
        memberReqsPath: FieldValue.arrayRemove([AppUser.account.uid]),
      },
    );
  } catch (e) {
    popNLog(context, e.toString());
  }
}

// Reset the active members field of the passed signal
Future<void> resetSignal(BuildContext context, String title) async {
  try {
    await AppUser.db.collection(signalsPath).doc(title).update(
      {activeMembersPath: []},
    );
  } catch (e) {
    popNLog(context, e.toString());
  }
}

// Optionally update the notification message of the passed signal
void updateMessage(BuildContext context, String title) {
  final messageFormKey = GlobalKey<FormState>();
  TextEditingController _messageController = TextEditingController();

  ezDialog(
    context: context,
    title: 'New message...',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Text field
        ezForm(
          key: messageFormKey,
          controller: _messageController,
          hintText: 'Notification',
          validator: signalMessageValidator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        Container(height: AppConfig.prefs[dialogSpacingKey]),

        // Yes/no buttons
        ezYesNo(
            context: context,
            onConfirm: () async {
              // Don't do anything if the message is invalid
              if (!messageFormKey.currentState!.validate()) {
                popNLog(context, 'Invalid message!');
                return;
              }

              Navigator.of(context).popUntil(ModalRoute.withName(homeRoute));
              try {
                // Upload the new message
                String message = _messageController.text.trim();
                await AppUser.db.collection(signalsPath).doc(title).update(
                  {messagePath: message},
                );
              } catch (e) {
                popNLog(context, e.toString());
              }
            },
            onDeny: () => Navigator.of(context).popUntil(ModalRoute.withName(homeRoute)),
            axis: Axis.horizontal),
      ],
    ),
  );
}

// Optionally transfer the signal to a new owner in firestore
void confirmTransfer(BuildContext context, String title, List<String> members) {
  double dialogSpacer = AppConfig.prefs[dialogSpacingKey];

  List<String> others = new List.from(members);
  others.remove(AppUser.account.uid);

  // Build a list of profile buttons that, on tap, update ownership in the db
  Widget buildSelectors(List<UserProfile> memberProfiles) {
    // Return an "avatar" of the none icon if there are no other members
    if (memberProfiles.isEmpty)
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(PlatformIcons(context).clear, size: 35),
          Container(height: dialogSpacer),
        ],
      );

    List<Widget> children = [];

    // Build the rows
    memberProfiles.forEach((profile) {
      children.addAll([
        GestureDetector(
          onTap: () async {
            Navigator.of(context).popUntil(ModalRoute.withName(homeRoute));
            try {
              // Set the owner to "this" user
              await AppUser.db.collection(signalsPath).doc(title).update(
                {ownerPath: profile.id},
              );
            } catch (e) {
              popNLog(context, e.toString());
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Profile image/avatar
              CircleAvatar(
                foregroundImage: CachedNetworkImageProvider(profile.avatarURL),
                minRadius: 35,
                maxRadius: 35,
              ),

              // Display name
              paddedText(
                profile.name,
                style: getTextStyle(dialogTitleStyleKey),
                alignment: TextAlign.start,
              ),
            ],
          ),
        ),
        Container(height: dialogSpacer),
      ]);
    });

    return ezScrollView(children: children, centered: true);
  }

  // Actual pop-up
  ezDialog(
    context: context,
    title: 'Select user',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: streamUsers(others),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return loadingMessage(
                  context: context,
                  image: buildImage(
                    path: AppConfig.prefs[signalImageKey],
                    isAsset: isAssetImage(AppConfig.prefs[signalImageKey]),
                  ),
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

                return buildSelectors(buildProfiles(snapshot.data!.docs));
            }
          },
        ),
        ezCancel(
          context: context,
          onCancel: () => Navigator.of(context).popUntil(ModalRoute.withName(homeRoute)),
        ),
      ],
    ),
  );
}

// Optionally delete the signal in firestore and clear local prefs
void confirmDelete(BuildContext context, String title, List<String> prefKeys) {
  ezDialog(
    context: context,
    title: 'Delete $title?',
    content: ezYesNo(
      context: context,
      onConfirm: () async {
        Navigator.of(context).popUntil(ModalRoute.withName(homeRoute));
        try {
          // Clear local prefs for the signal
          prefKeys.forEach((key) {
            AppConfig.preferences.remove(key);
          });

          // Delete the signal from the db
          await AppUser.db.collection(signalsPath).doc(title).delete();
        } catch (e) {
          popNLog(context, e.toString());
        }
      },
      onDeny: () => Navigator.of(context).popUntil(ModalRoute.withName(homeRoute)),
      axis: Axis.vertical,
    ),
  );
}

// Optionally delete the signal in firestore and clear local prefs
void confirmDeparture(BuildContext context, String title, List<String> prefKeys) {
  ezDialog(
    context: context,
    title: 'Leave $title?',
    content: ezYesNo(
        context: context,
        onConfirm: () async {
          Navigator.of(context).popUntil(ModalRoute.withName(homeRoute));
          try {
            // Clear local prefs for the signal
            prefKeys.forEach((key) {
              AppConfig.preferences.remove(key);
            });

            // Remove the current user from the list of members
            await AppUser.db.collection(signalsPath).doc(title).update(
              {
                membersPath: FieldValue.arrayRemove([AppUser.account.uid])
              },
            );
          } catch (e) {
            popNLog(context, e.toString());
          }
        },
        onDeny: () => Navigator.of(context).popUntil(ModalRoute.withName(homeRoute)),
        axis: Axis.vertical),
  );
}
