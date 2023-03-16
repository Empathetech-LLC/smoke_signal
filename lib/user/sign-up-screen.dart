import '../user/user-api.dart';
import '../utils/helpers.dart';
import '../utils/validate.dart';
import '../utils/material-ui.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);

  late TextStyle contents = getTextStyle(dialogContentStyleKey);

  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

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
                      onPressed: () {},
                      child: TextFormField(
                        cursorColor: themeTextColor,
                        controller: _signupEmailController,
                        textAlign: TextAlign.center,
                        style: contents,
                        decoration: InputDecoration(
                          hintText: 'Enter email',
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
                      onPressed: () {},
                      child: TextFormField(
                        controller: _passwdController,
                        textAlign: TextAlign.center,
                        style: contents,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Enter password',
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
                AppConfig.focus.primaryFocus?.unfocus();

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
              PlatformText('Sign up'),
            ),
          ],
        ),
      ),

      // Background image/decoration
      buildDecoration(AppConfig.prefs[backImageKey]),

      // Fallback background color
      Color(AppConfig.prefs[backColorKey]),

      // Android drawer aka settings hamburger
      standardDrawer(context),

      // iOS nav (top) bar
      null,
    );
  }
}
