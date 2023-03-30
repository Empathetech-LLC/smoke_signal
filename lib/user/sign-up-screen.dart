import '../user/user-api.dart';
import '../utils/validate.dart';
import '../utils/drawers.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _signupEmailController = TextEditingController();
  late TextEditingController _passwdController = TextEditingController();

  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);

  late TextStyle contents = getTextStyle(dialogContentStyleKey);

  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

  @override
  Widget build(BuildContext context) {
    return ezScaffold(
      context: context,

      // Title & theme
      title: 'Welcome!',
      backgroundImage: buildDecoration(AppConfig.prefs[backImageKey]),
      backgroundColor: Color(AppConfig.prefs[backColorKey]),

      // Body
      body: ezScrollView(
        children: [
          AutofillGroup(
            child: Column(
              children: [
                // Email field
                ezForm(
                  key: emailFormKey,
                  controller: _signupEmailController,
                  hintText: 'Enter email',
                  autofillHints: [AutofillHints.email],
                  validator: emailValidator,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                Container(height: buttonSpacer),

                // Password field
                ezForm(
                  key: passwordFormKey,
                  controller: _passwdController,
                  hintText: 'Enter password',
                  private: true,
                  autofillHints: [AutofillHints.password],
                ),
              ],
            ),
          ),
          Container(height: buttonSpacer),

          // Attempt sign up button
          EZButton(
            action: () async {
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
            body: Text('Sign up'),
          ),
        ],
        centered: true,
      ),

      // User interaction
      drawerHeader: standardDrawerHeader(),
      drawerBody: standardDrawerBody(context),
    );
  }
}
