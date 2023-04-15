import 'screens.dart';
import '../utils/utils.dart';

import 'package:empathetech_ss_api/empathetech_ss_api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SignalBoard extends StatefulWidget {
  const SignalBoard({Key? key}) : super(key: key);

  @override
  _SignalBoardState createState() => _SignalBoardState();
}

class _SignalBoardState extends State<SignalBoard> {
  double buttonSpacer = EzConfig.prefs[buttonSpacingKey];

  late Stream<QuerySnapshot<Object?>> _signalStream;
  late Stream<QuerySnapshot<Object?>> _requestStream;

  @override
  void initState() {
    super.initState();
    _signalStream = streamSignals(membersPath);
    _requestStream = streamSignals(memberReqsPath);
  }

  void refresh() {
    setState(doNothing);
  }

  void reload() {
    setState(() {
      _signalStream = streamSignals(membersPath);
      _requestStream = streamSignals(memberReqsPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return EzScaffold(
      background: BoxDecoration(color: Color(EzConfig.prefs[backColorKey])),

      // App bar
      appBar: EzAppBar(
        title: EzText.simple('Signals', style: buildTextStyle(style: titleStyleKey)),

        // End Drawer
        trailing: EzDrawer(
          header: signalDrawerHeader(context: context, refresh: refresh),
          body: [
            Container(height: buttonSpacer),

            // GoTo settings
            EzButton.icon(
              action: () async {
                dynamic shouldRefresh = await popAndPushScreen(
                  context: context,
                  screen: AppSettingsScreen(),
                );

                if (shouldRefresh != null) refresh();
              },
              message: 'Settings',
              icon: EzIcon(PlatformIcons(context).settings),
            ),
            Container(height: buttonSpacer),

            // Show input rules
            EzButton(
              action: () => openDialog(
                context: context,
                dialog: EzDialog(
                  title: EzText.simple(
                    'Input rules',
                    style: buildTextStyle(style: dialogContentStyleKey),
                  ),
                  contents: [
                    EzText.simple(
                      validatorRule,
                      style: buildTextStyle(style: dialogContentStyleKey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              body: EzText.simple('Input rules'),
            ),
            Container(height: buttonSpacer),

            // Reload
            EzButton.icon(
              action: () {
                popScreen(context: context, pass: true);
                reload();
              },
              message: 'Reload',
              icon: EzIcon(PlatformIcons(context).refresh),
            ),
          ],
        ),
      ),

      // Body
      body: standardView(
        context: context,
        background: BoxDecoration(
          image: DecorationImage(image: EzImage.getProvider(backImageKey)),
        ),
        body: EzScrollView(
          children: [
            // Signals the user is a member of
            StreamBuilder<QuerySnapshot>(
                stream: _signalStream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return loadingMessage(
                        context: context,
                        image: EzImage(prefsKey: signalImageKey),
                      );
                    case ConnectionState.done:
                    default:
                      if (snapshot.hasError) {
                        logAlert(context, snapshot.error.toString());
                        return Container();
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot signalDoc) =>
                                Signal.buildSignal(signalDoc, reload))
                            .toList(),
                      );
                  }
                }),

            // Signal requests pending the user's approval
            StreamBuilder<QuerySnapshot>(
                stream: _requestStream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Container(); // Don't need two loading messages
                    case ConnectionState.done:
                    default:
                      if (snapshot.hasError) {
                        logAlert(context, snapshot.error.toString());
                        return Container();
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot signalDoc) =>
                                Signal.buildSignal(signalDoc, reload))
                            .toList(),
                      );
                  }
                }),
          ],
          centered: true,
        ),
      ),

      // Floating Action Button
      fab: EzButton(
        action: () async {
          dynamic shouldReload = await pushScreen(
            context: context,
            screen: CreateSignalScreen(),
          );

          if (shouldReload != null) reload();
        },
        body: EzIcon(PlatformIcons(context).add),
      ),
    );
  }
}
