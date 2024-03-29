import 'reset-password.dart';
import '../utils/drawers.dart';

import 'package:empathetech_ss_api/empathetech_ss_api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _passwdController = TextEditingController();

  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);

  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

  late TextStyle contents = getTextStyle(dialogContentStyleKey);

  @override
  Widget build(BuildContext context) {
    return EZScaffold(
      // Title && theme
      title: 'Welcome back!',
      backgroundImage: buildDecoration(AppConfig.prefs[backImageKey]),
      backgroundColor: Color(AppConfig.prefs[backColorKey]),

      // Body
      body: ezScrollView(
        children: [
          // Autofill group allows for password manager inputs and such
          AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Email field
                ezForm(
                  key: emailFormKey,
                  controller: _emailController,
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

          // Forgot password option
          GestureDetector(
            onTap: () => pushScreen(
              context,
              screen: ResetPasswordScreen(),
            ),
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
          EZButton(
            action: () async {
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
            body: Text('Login'),
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
