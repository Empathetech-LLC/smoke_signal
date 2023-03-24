import '../utils/validate.dart';
import '../user/user-api.dart';
import '../utils/drawers.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
    return ezScaffold(
      context: context,

      title: 'No problem!',

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
          ezIconButton(
            action: () async {
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
            message: 'Send link',
            icon: ezIcon(PlatformIcons(context).mail),
          ),
          Container(height: buttonSpacer),
        ],
        centered: true,
      ),

      // Background image/decoration
      backgroundImage: buildDecoration(AppConfig.prefs[backImageKey]),

      // Fallback background color
      backgroundColor: Color(AppConfig.prefs[backColorKey]),

      // Scaffold config
      scaffoldConfig: MaterialScaffoldData(endDrawer: standardDrawer(context)),
    );
  }
}
