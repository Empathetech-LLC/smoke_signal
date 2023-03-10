import '../utils/storage.dart';
import '../utils/custom-widgets.dart';
import '../utils/helpers.dart';
import '../user/user-api.dart';
import '../utils/scaffolds.dart';
import '../utils/constants.dart';
import '../utils/text.dart';

import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //// Initialize state

  final emailFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _passwdController = TextEditingController();

  // Gather theme data
  late Color themeTextColor = Color(AppUser.prefs[themeTextColorKey]);

  late double buttonSpacer = AppUser.prefs[buttonSpacingKey];

  late TextStyle contents = getTextStyle(dialogContentStyle);

  @override
  Widget build(BuildContext context) {
    return standardScaffold(
      context,

      // Title
      'Welcome back!',

      // Body
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Autofill group allows for password manager inputs and such
            AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Email field
                  Form(
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

            // Forgot password option
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(resetPasswordRoute),
              child: Text(
                'Forgot your password?',
                style: TextStyle(
                  color: contents.color,
                  fontSize: contents.fontSize,
                  fontFamily: contents.fontFamily,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Container(height: buttonSpacer),

            // Attempt login button
            ezButton(
              () async {
                // Close keyboard if open
                AppUser.focus.primaryFocus?.unfocus();

                // Don't attempt login if we know the input is invalid
                if (!emailFormKey.currentState!.validate()) {
                  popNLog(context, 'Invalid email!');
                  return;
                }

                await attemptLogin(
                  context,
                  _emailController.text.trim(),
                  _passwdController.text.trim(),
                );
              },
              () {},
              Text('Login'),
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
