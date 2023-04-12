import 'screens.dart';
import '../utils/utils.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late double buttonSpacer = EzConfig.prefs[buttonSpacingKey];

  @override
  Widget build(BuildContext context) {
    return EzScaffold(
      background: BoxDecoration(color: Color(EzConfig.prefs[backColorKey])),
      appBar: EzAppBar(
        title: Text(
          appTitle,
          style: buildTextStyle(style: titleStyleKey),
        ),
        trailing: EzDrawer(
          header: standardDrawerHeader(),
          body: standardDrawerBody(context: context),
        ),
      ),
      body: standardWindow(
        context: context,
        background: imageBackground(EzConfig.prefs[backImageKey]),
        body: ezScrollView(
          children: [
            // Login
            EzButton.icon(
              action: () => pushScreen(
                context: context,
                screen: LoginScreen(),
              ),
              message: 'Login',
              icon: ezIcon(PlatformIcons(context).mail),
            ),
            Container(height: buttonSpacer),

            // Sign up
            EzButton.icon(
              action: () => pushScreen(
                context: context,
                screen: SignUpScreen(),
              ),
              message: 'Sign up',
              icon: ezIcon(PlatformIcons(context).mail),
            ),
          ],
          centered: true,
        ),
      ),
    );
  }
}
