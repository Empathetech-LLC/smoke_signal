import '../utils/constants.dart';
import '../utils/validate.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AppUser {
  static late FirebaseMessaging messager;
  static late FirebaseAuth auth;
  static late User account;
  static late FirebaseFirestore db;
}

class UserProfile {
  String id;
  String name;
  String avatarURL;

  UserProfile(this.id, this.name, this.avatarURL);

  /// Builds a local UserProfile from a Firestore (user) DocumentSnapshot
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

/// Attempt creating a new firebase user account
/// (can) cost money!!
/// Writing data free tier == 20k writes/day, 1GB limit
/// Reading data free tier == 50k reads/day

Future<void> attemptAccountCreation(
    BuildContext context, String email, String password) async {
  try {
    await AppUser.auth.createUserWithEmailAndPassword(email: email, password: password);

    // Successful login, return to the home screen
    Navigator.of(context).pop();
  } on FirebaseAuthException catch (e) {
    // Email is already in use, attempt login
    if (e.code == 'email-already-in-use') {
      popNLog(context, 'Email already in use, attempting login');
      await attemptLogin(context, email, password);
    }

    // Weak password
    else if (e.code == 'weak-password') {
      popNLog(context, 'The provided password is too weak');
    }

    // etc
    else {
      String message = 'Firebase error on user creation\n' + e.code;
      popNLog(context, message);
    }
  } catch (e) {
    String message = 'Error creating user\n' + e.toString();
    popNLog(context, message);
  }
}

// Attempt logging in firebase user with passed credentials
Future<void> attemptLogin(BuildContext context, String email, String password) async {
  try {
    await AppUser.auth.signInWithEmailAndPassword(email: email, password: password);

    // Successful login, return to the home screen
    Navigator.of(context).pop();
  } on FirebaseAuthException catch (e) {
    // Wrong username
    if (e.code == 'user-not-found') {
      popNLog(context, 'No user found for that email!');
    }

    // Wrong password
    else if (e.code == 'wrong-password') {
      popNLog(context, 'Incorrect password');
    }

    // etc
    else {
      String message = 'Error logging in\n' + e.code;
      popNLog(context, message);
    }
  }
}

// Logout current user
void logout(BuildContext context) {
  ezDialog(
    context: context,
    title: 'Logout?',
    content: ezYesNo(
      context: context,
      onConfirm: () async {
        Navigator.of(context).popUntil(ModalRoute.withName(homeRoute));
        await AppUser.auth.signOut();
      },
      onDeny: () => Navigator.of(context).pop(),
      axis: Axis.vertical,
      spacer: AppConfig.prefs[dialogSpacingKey],
    ),
  );
}

// Merge the current users FCM token with firestore
Future<void> setToken(User currUser) async {
  String userToken = await AppUser.messager.getToken() ?? '';

  // Set with merge here as update fails with no pre-existing doc
  await FirebaseFirestore.instance.collection(usersPath).doc(currUser.uid).set(
    {
      fcmTokenPath: userToken,
    },
    SetOptions(merge: true),
  );
}

// Stream user docs from db, optionally filtering by the list of ids we know we want
Stream<QuerySnapshot<Map<String, dynamic>>> streamUsers([List<String>? ids]) {
  try {
    if (ids == null) {
      return AppUser.db.collection(usersPath).snapshots();
    } else {
      return AppUser.db
          .collection(usersPath)
          .where(FieldPath.documentId, whereIn: ids)
          .snapshots();
    }
  } catch (e) {
    return Stream.empty();
  }
}

// Return the FCM token of the user with the passed ID
Future<String> getToken(String id) async {
  try {
    DocumentSnapshot userSnap = await AppUser.db.collection(usersPath).doc(id).get();
    final data = userSnap.data() as Map<String, dynamic>;
    return data[fcmTokenPath];
  } catch (e) {
    return '';
  }
}

// Get the FCM tokens for all the passed user ids
Future<List<String>> gatherTokens(List<String> ids) async {
  List<Future<String>> tokenReqs = ids.map((id) async => await getToken(id)).toList();
  List<String> tokens = await Future.wait(tokenReqs);

  tokens.removeWhere((token) => token == '');

  return tokens;
}

// Map all db user docs to local user profiles
List<UserProfile> buildProfiles(List<DocumentSnapshot> userDocs) {
  return userDocs
      .map((DocumentSnapshot userDoc) => UserProfile.buildFromDoc(userDoc))
      .toList();
}

// Displays a horizontally scrollable list of user profile pictures
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

// Displays list of user profile pics alongside their display names
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

// Update the users avatar
void editAvatar(BuildContext context) {
  final urlFormKey = GlobalKey<FormState>();
  TextEditingController _urlController = TextEditingController();

  double dialogSpacer = AppConfig.prefs[dialogSpacingKey];

  ezDialog(
    context: context,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // URL text field/form
        ezForm(
          key: urlFormKey,
          controller: _urlController,
          hintText: 'Enter URL',
          validator: urlValidator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        Container(height: dialogSpacer),

        // Explanation for not using image files
        Text(
          'Images are expensive to store!\nPaste an image link and that will be used',
          maxLines: 2,
          style: getTextStyle(dialogContentStyleKey),
          textAlign: TextAlign.center,
        ),
        Container(height: dialogSpacer),

        // Submit & cancel buttons
        ezYesNo(
          context: context,
          onConfirm: () async {
            // Close keyboard if open
            AppConfig.focus.primaryFocus?.unfocus();

            // Don't do anything if the url is invalid
            if (!urlFormKey.currentState!.validate()) {
              popNLog(context, 'Invalid URL!');
              return;
            }

            // Save text & close dialog
            String photoURL = _urlController.text.trim();
            Navigator.of(context).pop();

            // Update firestore and the firebase user config
            await AppUser.account.updatePhotoURL(photoURL);
            await AppUser.db.collection(usersPath).doc(AppUser.account.uid).update(
              {avatarURLPath: photoURL},
            );
          },
          onDeny: () => Navigator.of(context).pop(),
          axis: Axis.horizontal,
          spacer: dialogSpacer,
          confirmMsg: 'Submit',
          denyMsg: 'Cancel',
        ),
      ],
    ),
  );
}

// Update the users display name
void editName(BuildContext context) {
  final nameFormKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();

  double dialogSpacer = AppConfig.prefs[dialogSpacingKey];

  ezDialog(
    context: context,
    title: 'Who are you?',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Name field
        ezForm(
          key: nameFormKey,
          controller: _nameController,
          hintText: 'Enter display name',
          validator: displayNameValidator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        Container(height: dialogSpacer),

        // Submit & cancel buttons
        ezYesNo(
          context: context,
          onConfirm: () async {
            // Close keyboard if open
            AppConfig.focus.primaryFocus?.unfocus();

            // Don't do anything if the display name is invalid
            if (!nameFormKey.currentState!.validate()) {
              popNLog(context, 'Invalid display name!');
              return;
            }

            // Save text & close dialog
            String newName = _nameController.text.trim();
            Navigator.of(context).pop();

            // Update firestore and the firebase user config
            await AppUser.account.updateDisplayName(newName);
            await AppUser.db.collection(usersPath).doc(AppUser.account.uid).update(
              {displayNamePath: newName},
            );
          },
          onDeny: () => Navigator.of(context).pop(),
          axis: Axis.horizontal,
          spacer: dialogSpacer,
          confirmMsg: 'Submit',
          denyMsg: 'Cancel',
        ),
      ],
    ),
  );
}
