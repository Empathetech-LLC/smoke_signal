import '../utils/constants.dart';
import '../utils/custom-widgets.dart';
import '../utils/storage.dart';
import '../utils/helpers.dart';
import '../user/user-api.dart';
import '../utils/scaffolds.dart';
import '../utils/text.dart';

import 'package:flutter/material.dart';

class ResetScreen extends StatefulWidget {
  const ResetScreen({super.key});

  @override
  _ResetScreenState createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  // Gather instance data
  final emailFormKey = GlobalKey<FormState>();

  late TextEditingController _emailController = TextEditingController();

  // Gather theme data
  late Color themeTextColor = Color(AppUser.prefs[themeTextColorKey]);

  late TextStyle contents = getTextStyle(dialogContentStyle);

  late double buttonSpacer = AppUser.prefs[buttonSpacingKey];

  @override
  Widget build(BuildContext context) {
    return standardScaffold(
      context,

      // Title
      'No problem!',

      // Body
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Email form
            AutofillGroup(
              child: Form(
                key: emailFormKey,
                child: OutlinedButton(
                  style: textFieldStyle(),
                  onPressed: () {},
                  child: TextFormField(
                    cursorColor: themeTextColor,
                    controller: _emailController,
                    textAlign: TextAlign.center,
                    style: contents,
                    decoration: InputDecoration(
                      hintText: 'Enter email',
                      border: blankBorder(),
                      focusedBorder: blankBorder(),
                    ),
                    autofillHints: [AutofillHints.email],
                    validator: emailValidator,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
              ),
            ),
            Container(height: buttonSpacer),

            // Submit button
            ezIconButton(
              () async {
                // Close keyboard if open
                AppUser.focus.primaryFocus?.unfocus();

                // Don't do anything if the email is invalid
                if (!emailFormKey.currentState!.validate()) {
                  popNLog(context, 'Invalid email!');
                  return;
                }

                // Attempt reset
                try {
                  await AppUser.auth
                      .sendPasswordResetEmail(email: _emailController.text.trim());
                  popNLog(context, 'Password reset email has been sent!');
                } on Exception catch (e) {
                  popNLog(context, 'Failed to send password reset email:\n$e');
                }
              },
              () {},
              Icon(Icons.email),
              Text('Send link'),
            ),
            Container(height: buttonSpacer),
          ],
        ),
      ),

      // Background image/decoration
      buildDecoration(AppUser.prefs[appImageKey]),

      // Fallback background color
      Color(AppUser.prefs[appBackgroundColorKey]),

      // Drawer aka settings hamburger
      settingsDrawer(context),
    );
  }
}
