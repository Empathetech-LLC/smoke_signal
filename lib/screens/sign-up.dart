import '../utils/utils.dart';

import 'package:empathetech_ss_api/empathetech_ss_api.dart';
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

  late TextEditingController _signUpEmailController = TextEditingController();
  late TextEditingController _passwdController = TextEditingController();

  late Color themeTextColor = Color(EzConfig.prefs[themeTextColorKey]);

  late TextStyle contents = buildTextStyle(style: dialogContentStyleKey);

  late double buttonSpacer = EzConfig.prefs[buttonSpacingKey];

  @override
  Widget build(BuildContext context) {
    return EzScaffold(
      background: BoxDecoration(color: Color(EzConfig.prefs[backColorKey])),
      appBar: EzAppBar(
        title: Text('Welcome!', style: buildTextStyle(style: titleStyleKey)),
        trailing: EzDrawer(
          header: standardDrawerHeader(),
          body: standardDrawerBody(context: context),
        ),
      ),

      // Body
      body: standardWindow(
        context: context,
        background: imageBackground(EzConfig.prefs[backImageKey]),
        body: EzScrollView(
          children: [
            AutofillGroup(
              child: Column(
                children: [
                  // Email field
                  ezForm(
                    key: emailFormKey,
                    controller: _signUpEmailController,
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
            EzButton(
              action: () async {
                // Close keyboard if open
                EzConfig.focus.primaryFocus?.unfocus();

                // Don't do anything if the input is invalid
                if (!emailFormKey.currentState!.validate()) {
                  logAlert(context, 'Invalid email!');
                  return;
                }

                // Attempt login
                await attemptAccountCreation(
                  context,
                  _signUpEmailController.text.trim(),
                  _passwdController.text.trim(),
                );
              },
              body: Text('Sign up'),
            ),
          ],
          centered: true,
        ),
      ),
    );
  }
}
