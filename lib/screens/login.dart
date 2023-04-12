import 'screens.dart';
import '../utils/utils.dart';

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

  late Color themeTextColor = Color(EzConfig.prefs[themeTextColorKey]);

  late double buttonSpacer = EzConfig.prefs[buttonSpacingKey];

  late TextStyle contents = buildTextStyle(style: dialogContentStyleKey);

  @override
  Widget build(BuildContext context) {
    return EzScaffold(
      background: BoxDecoration(color: Color(EzConfig.prefs[backColorKey])),
      appBar: EzAppBar(
        title: Text('Welcome back!', style: buildTextStyle(style: titleStyleKey)),
        trailing: EzDrawer(
          header: standardDrawerHeader(),
          body: standardDrawerBody(context: context),
        ),
      ),

      // Body
      body: standardWindow(
        context: context,
        background: imageBackground(EzConfig.prefs[backImageKey]),
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
                context: context,
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
                EzConfig.focus.primaryFocus?.unfocus();

                // Don't attempt login if we know the input is invalid
                if (!emailFormKey.currentState!.validate()) {
                  logAlert(context, 'Invalid email!');
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
      ),
    );
  }
}
