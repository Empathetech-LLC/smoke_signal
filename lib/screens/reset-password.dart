import '../utils/utils.dart';

import 'package:empathetech_ss_api/empathetech_ss_api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetScreenState createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetPasswordScreen> {
  final emailFormKey = GlobalKey<FormState>();

  late TextEditingController _emailController = TextEditingController();

  late Color themeTextColor = Color(EzConfig.prefs[themeTextColorKey]);

  late TextStyle contents = getTextStyle(dialogContentStyleKey);

  late double buttonSpacer = EzConfig.prefs[buttonSpacingKey];

  @override
  Widget build(BuildContext context) {
    return EzScaffold(
      background: BoxDecoration(color: Color(EzConfig.prefs[backColorKey])),
      appBar: EzAppBar(
        title: Text('No problem!', style: getTextStyle(titleStyleKey)),
        endDrawer: EzDrawer(
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
            // Email form
            AutofillGroup(
              child: ezForm(
                key: emailFormKey,
                controller: _emailController,
                hintText: 'Enter email',
                autofillHints: [AutofillHints.email],
                validator: emailValidator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
            Container(height: buttonSpacer),

            // Submit button
            EZButton.icon(
              action: () async {
                // Close keyboard if open
                EzConfig.focus.primaryFocus?.unfocus();

                // Don't do anything if the email is invalid
                if (!emailFormKey.currentState!.validate()) {
                  logAlert(context, 'Invalid email!');
                  return;
                }

                // Attempt reset
                try {
                  await AppUser.auth
                      .sendPasswordResetEmail(email: _emailController.text.trim());
                  logAlert(context, 'Password reset email has been sent!');
                } on Exception catch (e) {
                  logAlert(context, 'Failed to send password reset email:\n$e');
                }
              },
              message: 'Send link',
              icon: ezIcon(PlatformIcons(context).mail),
            ),
            Container(height: buttonSpacer),
          ],
          centered: true,
        ),
      ),
    );
  }
}
