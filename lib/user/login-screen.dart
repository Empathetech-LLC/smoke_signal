import '../utils/helpers.dart';
import '../user/user-api.dart';
import '../utils/material-ui.dart';
import '../utils/constants.dart';
import '../utils/validate.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);

  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

  late TextStyle contents = getTextStyle(dialogContentStyleKey);

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
                      onPressed: () {},
                      child: TextFormField(
                        cursorColor: themeTextColor,
                        controller: _emailController,
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

            // Forgot password option
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(resetPasswordRoute),
              child: PlatformText(
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
                AppConfig.focus.primaryFocus?.unfocus();

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
              PlatformText('Login'),
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
