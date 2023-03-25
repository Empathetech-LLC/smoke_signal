import '../utils/constants.dart';
import '../utils/validate.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Wrapper for housing all Firebase instances
class AppUser {
  static late FirebaseMessaging messager;
  static late FirebaseAuth auth;
  static late User account;
  static late FirebaseFirestore db;
}

/// Attempt creating a new firebase user account
/// Can cost money!!
///   Writing data free tier == 20k writes/day, 1GB limit
///   Reading data free tier == 50k reads/day
Future<void> attemptAccountCreation(
    BuildContext context, String email, String password) async {
  try {
    await AppUser.auth.createUserWithEmailAndPassword(email: email, password: password);

    // Successful login, return to the home screen
    Navigator.of(context).pop();
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'email-already-in-use':
        popNLog(context, 'Email already in use, attempting login');
        await attemptLogin(context, email, password);
        break;

      case 'weak-password':
        popNLog(context, 'The provided password is too weak');
        break;

      default:
        String message = 'Firebase error on user creation\n' + e.code;
        popNLog(context, message);
        break;
    }
  } catch (e) {
    String message = 'Error creating user\n' + e.toString();
    popNLog(context, message);
  }
}

/// Attempt logging in firebase user with passed credentials
Future<void> attemptLogin(BuildContext context, String email, String password) async {
  try {
    await AppUser.auth.signInWithEmailAndPassword(email: email, password: password);

    // Successful login, return to the home screen
    Navigator.of(context).pop();
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'user-not-found':
        popNLog(context, 'No user found for that email!');
        break;

      case 'wrong-password':
        popNLog(context, 'Incorrect password');
        break;

      default:
        String message = 'Error logging in\n' + e.code;
        popNLog(context, message);
        break;
    }
  }
}

/// Logout current user
void logout(BuildContext context) {
  ezDialog(
    context: context,
    title: 'Logout?',
    content: ezYesNo(
      context: context,
      onConfirm: () async {
        Navigator.of(context).pop();
        await AppUser.auth.signOut();
      },
      onDeny: () => Navigator.of(context).pop(),
      axis: Axis.vertical,
      spacer: AppConfig.prefs[dialogSpacingKey],
    ),
  );
}

/// Merge the current users FCM token with firestore
/// Can cost money!!
///   Writing data free tier == 20k writes/day, 1GB limit
///   Reading data free tier == 50k reads/day
Future<void> setToken(User currUser) async {
  String userToken = await AppUser.messager.getToken() ?? '';

  // The doc may not exist yet, so use set w/ merge
  await FirebaseFirestore.instance.collection(usersPath).doc(currUser.uid).set(
    {fcmTokenPath: userToken},
    SetOptions(merge: true),
  );
}

/// Stream user docs from db, optionally filtering by the list of ids we know we want
/// Can cost money!!
///   Writing data free tier == 20k writes/day, 1GB limit
///   Reading data free tier == 50k reads/day
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

/// Return the FCM token of the user with the passed ID
/// Can cost money!!
///   Writing data free tier == 20k writes/day, 1GB limit
///   Reading data free tier == 50k reads/day
Future<String> getToken(String id) async {
  try {
    DocumentSnapshot userSnap = await AppUser.db.collection(usersPath).doc(id).get();

    final data = userSnap.data() as Map<String, dynamic>;

    return data[fcmTokenPath];
  } catch (e) {
    return '';
  }
}

/// Get the FCM tokens for all the passed user ids
/// Can cost money!!
///   Writing data free tier == 20k writes/day, 1GB limit
///   Reading data free tier == 50k reads/day
Future<List<String>> gatherTokens(List<String> ids) async {
  List<Future<String>> tokenReqs = ids.map((id) async => await getToken(id)).toList();
  List<String> tokens = await Future.wait(tokenReqs);

  tokens.removeWhere((token) => token == '');

  return tokens;
}

/// Update the users avatar
/// Can cost money!!
///   Writing data free tier == 20k writes/day, 1GB limit
///   Reading data free tier == 50k reads/day
void editAvatar(BuildContext context) {
  final urlFormKey = GlobalKey<FormState>();
  TextEditingController _urlController = TextEditingController();

  double dialogSpacer = AppConfig.prefs[dialogSpacingKey];

  ezDialog(
    context: context,
    needsClose: false,
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
          axis: Axis.vertical,
          spacer: dialogSpacer,
          confirmMsg: 'Submit',
          denyMsg: 'Cancel',
        ),
      ],
    ),
  );
}

/// Update the users display name
/// Can cost money!!
///   Writing data free tier == 20k writes/day, 1GB limit
///   Reading data free tier == 50k reads/day
void editName(BuildContext context) {
  final nameFormKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();

  double dialogSpacer = AppConfig.prefs[dialogSpacingKey];

  ezDialog(
    context: context,
    title: 'Who are you?',
    needsClose: false,
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
          axis: Axis.vertical,
          spacer: dialogSpacer,
          confirmMsg: 'Submit',
          denyMsg: 'Cancel',
        ),
      ],
    ),
  );
}
