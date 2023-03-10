import '../utils/custom-widgets.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/text.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

////// Wrapper classes //////

class AppUser {
  static Map<String, dynamic> prefs = new Map<String, dynamic>.from(appDefaults);

  static late FocusManager focus;
  static late SharedPreferences preferences;

  static late FirebaseMessaging messager;
  static late FirebaseAuth auth;
  static late User account;
  static late FirebaseFirestore db;

  // Populate prefs
  // Overwrite defaults whenever a user value is found
  static void init() {
    appDefaults.forEach((key, value) {
      dynamic userPref;

      if (value is int) {
        userPref = preferences.getInt(key);
      } else if (value is bool) {
        userPref = preferences.getBool(key);
      } else if (value is double) {
        userPref = preferences.getDouble(key);
      } else if (value is String) {
        userPref = preferences.getString(key);
      } else if (value is List<String>) {
        userPref = preferences.getStringList(key);
      }

      if (userPref != null) prefs[key] = userPref;
    });
  }
}

class UserProfile {
  String id;
  String name;
  String avatarURL;

  UserProfile(this.id, this.name, this.avatarURL);

  // Build local user profile from firestore user document
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

////// Custom functions //////

//// These (can) cost money!!
////   Writing data free tier == 20k writes/day, 1GB limit
////   Reading data free tier == 50k reads/day

//// Authentication

// Attempt creating a new firebase user account
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
      popNLog(context, 'The provided password is too weak', 5);
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
      popNLog(context, message, 5);
    }
  }
}

// Logout current user
void logout(BuildContext context) {
  double dialogSpacer = AppUser.prefs[dialogSpacingKey];

  ezDialog(
    context,
    'Logout?',
    [
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Yes
          ezIconButton(
            () async {
              Navigator.of(context).popUntil(ModalRoute.withName(homeRoute));
              await AppUser.auth.signOut();
            },
            () {},
            Icon(Icons.check),
            PlatformText('Yes'),
          ),
          Container(height: dialogSpacer),

          // No
          ezIconButton(
            () => Navigator.of(context).pop(),
            () {},
            Icon(Icons.cancel),
            PlatformText('No'),
          ),
          Container(height: dialogSpacer),
        ],
      )
    ],
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

//// Communication

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
  if (profiles.isEmpty)
    return CircleAvatar(
      backgroundColor: Colors.white,
      foregroundImage: AssetImage(noneIconPath),
      minRadius: 35,
      maxRadius: 35,
    );

  List<Widget> children = [];

  // Build the avatars
  profiles.forEach((profile) {
    children.addAll(
      [
        GestureDetector(
          // On long press: diplay the user's profile name
          onLongPress: () => ezDialog(
            context,
            null,
            [paddedPlatformText(profile.name, dialogTitleStyle, TextAlign.center)],
          ),
          child: CircleAvatar(
            backgroundImage: AssetImage(loadingGifPath),
            foregroundImage: CachedNetworkImageProvider(profile.avatarURL),
            minRadius: 35,
            maxRadius: 35,
          ),
        ),
        Container(width: padding),
      ],
    );
  });

  return ezCenterScroll(
    children,
    MainAxisSize.max,
    MainAxisAlignment.spaceEvenly,
    Axis.horizontal,
  );
}

// Displays list of user profile pics alongside their display names
Widget showUserProfiles(BuildContext context, List<UserProfile> profiles) {
  double dialogSpacer = AppUser.prefs[dialogSpacingKey];

  // Return an "avatar" with the none icon when the list is empty
  if (profiles.isEmpty)
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          foregroundImage: AssetImage(noneIconPath),
          minRadius: 35,
          maxRadius: 35,
        ),
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
            backgroundImage: AssetImage(loadingGifPath),
            foregroundImage: CachedNetworkImageProvider(profile.avatarURL),
            minRadius: 35,
            maxRadius: 35,
          ),

          // Display name
          paddedPlatformText(profile.name, dialogTitleStyle, TextAlign.start),
        ],
      ),
      Container(height: dialogSpacer),
    ]);
  });

  return ezCenterScroll(children);
}

//// Personalization

// Update the users avatar
void editAvatar(BuildContext context) {
  final urlFormKey = GlobalKey<FormState>();
  TextEditingController _urlController = TextEditingController();

  double dialogSpacer = AppUser.prefs[dialogSpacingKey];

  ezDialog(
    context,
    null,
    [
      // URL text field/form
      Form(
        key: urlFormKey,
        child: OutlinedButton(
          style: textFieldStyle(),
          onPressed: () {},
          child: TextFormField(
            cursorColor: Color(AppUser.prefs[themeColorKey]),
            controller: _urlController,
            textAlign: TextAlign.center,
            style: getTextStyle(dialogContentStyle),
            decoration: InputDecoration(
              hintText: 'Enter URL',
              border: blankBorder(),
              focusedBorder: blankBorder(),
            ),
            validator: urlValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
      ),
      Container(height: dialogSpacer),

      // Explanation for not using image files
      PlatformText(
        'Images are expensive to store!\nPaste an image link and that will be used',
        maxLines: 2,
        style: getTextStyle(dialogContentStyle),
        textAlign: TextAlign.center,
      ),
      Container(height: dialogSpacer),

      // Submit & cancel buttons
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Submit
          ezButton(
            () async {
              // Close keyboard if open
              AppUser.focus.primaryFocus?.unfocus();

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
            () {},
            PlatformText('Submit'),
          ),

          // Cancel
          ezIconButton(
            () => Navigator.of(context).pop(),
            () {},
            Icon(Icons.cancel),
            PlatformText('Cancel'),
          ),
        ],
      ),
    ],
  );
}

// Update the users display name
void editName(BuildContext context) {
  final nameFormKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();

  double dialogSpacer = AppUser.prefs[dialogSpacingKey];

  ezDialog(
    context,
    'Who are you?',
    [
      // Name field
      Form(
        key: nameFormKey,
        child: OutlinedButton(
          style: textFieldStyle(),
          onPressed: () {},
          child: TextFormField(
            cursorColor: Color(AppUser.prefs[themeColorKey]),
            controller: _nameController,
            textAlign: TextAlign.center,
            style: getTextStyle(dialogContentStyle),
            decoration: InputDecoration(
              hintText: 'Enter display name',
              border: blankBorder(),
              focusedBorder: blankBorder(),
            ),
            validator: displayNameValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
      ),
      Container(height: dialogSpacer),

      // Submit & cancel buttons
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Submit
          ezIconButton(
            () async {
              // Close keyboard if open
              AppUser.focus.primaryFocus?.unfocus();

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
            () {},
            Icon(Icons.check),
            PlatformText('Submit'),
          ),

          // Cancel
          ezIconButton(
            () => Navigator.of(context).pop(),
            () {},
            Icon(Icons.cancel),
            PlatformText('Cancel'),
          )
        ],
      ),
    ],
  );
}
