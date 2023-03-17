import '../user/user-api.dart';
import '../utils/helpers.dart';
import '../utils/validate.dart';
import '../utils/material-ui.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
                  ezForm(
                    emailFormKey,
                    _signupEmailController,
                    'Enter email',
                    false,
                    [AutofillHints.email],
                    emailValidator,
                    AutovalidateMode.onUserInteraction,
                  ),
                  Container(height: buttonSpacer),

                  // Password field
                  ezForm(
                    passwordFormKey,
                    _passwdController,
                    'Enter password',
                    true,
                    [AutofillHints.password],
                  ),
                ],
              ),
            ),
            Container(height: buttonSpacer),

            // Attempt sign up button
            ezTextButton(
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
              'Sign up',
            ),
          ],
        ),
      ),

      // Background image/decoration
      buildDecoration(AppConfig.prefs[backImageKey]),

      // Fallback background color
      Color(AppConfig.prefs[backColorKey]),

      // Android drawer aka settings hamburger
      MaterialScaffoldData(endDrawer: standardDrawer(context)),

      // iOS nav (top) bar
      null,
    );
  }
}
