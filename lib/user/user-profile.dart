import '../utils/constants.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Local mirror of Firebase [User] information
class UserProfile {
  String id;
  String name;
  String avatarURL;

  UserProfile(this.id, this.name, this.avatarURL);

  /// Builds a local [UserProfile] from a Firestore (user) [DocumentSnapshot]
  static UserProfile buildFromDoc(DocumentSnapshot userDoc) {
    final data = userDoc.data() as Map<String, dynamic>;
    return UserProfile(userDoc.id, data[displayNamePath], data[avatarURLPath]);
  }

  @override
  bool operator ==(Object other) =>
      other is UserProfile && this.id == other.id && this.name == other.name;

  @override
  int get hashCode => Object.hash(this.id, this.name);

  @override
  String toString() {
    return this.name;
  }
}

/// Map all db user docs to local user profiles
List<UserProfile> buildProfiles(List<DocumentSnapshot> userDocs) {
  return userDocs
      .map((DocumentSnapshot userDoc) => UserProfile.buildFromDoc(userDoc))
      .toList();
}

/// Displays a horizontally scrollable list of user profile pictures
Widget showUserPics(BuildContext context, List<UserProfile> profiles) {
  // Return an "avatar" with the none icon when the list is empty
  if (profiles.isEmpty) return ezIcon(PlatformIcons(context).clear, size: 35);

  List<Widget> children = [];

  // Build the avatars
  profiles.forEach((profile) {
    children.addAll(
      [
        GestureDetector(
          // On long press: diplay the user's profile name
          onLongPress: () => ezDialog(
            context: context,
            content: paddedText(
              profile.name,
              style: getTextStyle(dialogTitleStyleKey),
              alignment: TextAlign.center,
            ),
          ),
          child: CircleAvatar(
            foregroundImage: CachedNetworkImageProvider(profile.avatarURL),
            minRadius: 35,
            maxRadius: 35,
          ),
        ),
        Container(width: AppConfig.prefs[paddingKey]),
      ],
    );
  });

  return ezScrollView(
    children: children,
    centered: true,
    axisSize: MainAxisSize.max,
    axisAlign: MainAxisAlignment.spaceEvenly,
    direction: Axis.horizontal,
  );
}

/// Displays list of user profile pics alongside their display names
Widget showUserProfiles(BuildContext context, List<UserProfile> profiles) {
  double dialogSpacer = AppConfig.prefs[dialogSpacingKey];

  // Return an "avatar" with the none icon when the list is empty
  if (profiles.isEmpty)
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ezIcon(PlatformIcons(context).clear, size: 35),
        Container(height: dialogSpacer),
      ],
    );

  List<Widget> children = [];

  // Build the rows
  profiles.forEach((profile) {
    children.addAll([
      Row(
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
      Container(height: dialogSpacer),
    ]);
  });

  return ezScrollView(children: children, centered: true);
}
