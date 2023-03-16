import '../utils/helpers.dart';
import '../utils/validate.dart';
import '../user/user-api.dart';
import '../utils/material-ui.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ResetScreen extends StatefulWidget {
  const ResetScreen({super.key});

  @override
  _ResetScreenState createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  // Gather instance data
  final emailFormKey = GlobalKey<FormState>();

  late TextEditingController _emailController = TextEditingController();

  // Gather theme data
  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);

  late TextStyle contents = getTextStyle(dialogContentStyleKey);

  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

  @override
  Widget build(BuildContext context) {
    return standardScaffold(
      context,

      // Title
      'No problem!',

      // Body
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Email form
            AutofillGroup(
              child: ezForm(
                emailFormKey,
                _emailController,
                'Enter email',
                false,
                [AutofillHints.email],
                emailValidator,
                AutovalidateMode.onUserInteraction,
              ),
            ),
            Container(height: buttonSpacer),

            // Submit button
            ezIconButton(
              () async {
                // Close keyboard if open
                AppConfig.focus.primaryFocus?.unfocus();

                // Don't do anything if the email is invalid
                if (!emailFormKey.currentState!.validate()) {
                  popNLog(context, 'Invalid email!');
                  return;
                }

                // Attempt reset
                try {
                  await AppUser.auth
                      .sendPasswordResetEmail(email: _emailController.text.trim());
                  popNLog(context, 'Password reset email has been sent!');
                } on Exception catch (e) {
                  popNLog(context, 'Failed to send password reset email:\n$e');
                }
              },
              () {},
              Icon(Icons.email),
              Icon(Icons.email),
              PlatformText('Send link'),
            ),
            Container(height: buttonSpacer),
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
