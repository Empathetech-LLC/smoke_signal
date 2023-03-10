import '../utils/constants.dart';
import '../utils/storage.dart';
import '../utils/custom-widgets.dart';
import '../user/user-api.dart';
import '../utils/helpers.dart';
import '../utils/text.dart';
import '../utils/scaffolds.dart';

import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  //// Initialize state

  final emailFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _signupEmailController = TextEditingController();
  late TextEditingController _passwdController = TextEditingController();

  // Gather theme data
  late Color themeTextColor = Color(AppUser.prefs[themeTextColorKey]);

  late TextStyle contents = getTextStyle(dialogContentStyle);

  late double buttonSpacer = AppUser.prefs[buttonSpacingKey];

  //// Draw state

  @override
  Widget build(BuildContext context) {
    return standardScaffold(
      context,

      // Title
      'Welcome!',

      // Body
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Autofill group allows for password manager inputs and such
            AutofillGroup(
              child: Column(
                children: [
                  // Email field
                  Form(
                    key: emailFormKey,
                    child: OutlinedButton(
                      style: textFieldStyle(),
                      onPressed: () {},
                      child: TextFormField(
                        cursorColor: themeTextColor,
                        controller: _signupEmailController,
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
                  Container(height: buttonSpacer),

                  // Password field
                  Form(
                    key: passwordFormKey,
                    child: OutlinedButton(
                      style: textFieldStyle(),
                      onPressed: () {},
                      child: TextFormField(
                        controller: _passwdController,
                        textAlign: TextAlign.center,
                        style: contents,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          border: blankBorder(),
                          focusedBorder: blankBorder(),
                        ),
                        autofillHints: [AutofillHints.password],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: buttonSpacer),

            // Attempt sign up button
            ezButton(
              () async {
                // Close keyboard if open
                AppUser.focus.primaryFocus?.unfocus();

                // Don't do anything if the input is invalid
                if (!emailFormKey.currentState!.validate()) {
                  popNLog(context, 'Invalid email!');
                  return;
                }

                // Attempt login
                await attemptAccountCreation(
                  context,
                  _signupEmailController.text.trim(),
                  _passwdController.text.trim(),
                );
              },
              () {},
              Text('Sign up'),
            ),
          ],
        ),
      ),

      // Background image/decoration
      buildDecoration(AppUser.prefs[backImageKey]),

      // Fallback background color
      Color(AppUser.prefs[appBackgroundColorKey]),

      // Drawer aka settings hamburger
      settingsDrawer(context),
    );
  }
}
