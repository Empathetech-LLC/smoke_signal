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
      // Title && theme
      title: Text('Signals', style: getTextStyle(titleStyleKey)),
      backgroundImage: buildDecoration(EzConfig.prefs[backImageKey]),
      backgroundColor: Color(EzConfig.prefs[backColorKey]),

      // Body
      body: ezScrollView(
        children: [
          // Signals the user is a member of
          StreamBuilder<QuerySnapshot>(
              stream: _signalStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return loadingMessage(
                      context,
                      image: ezImage(pathKey: signalImageKey),
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

      // User interaction
      drawerHeader: signalDrawerHeader(context, refresh: refresh),
      drawerBody: [
        Container(height: buttonSpacer),

        // GoTo settings
        EZButton.icon(
          action: () async {
            dynamic shouldRefresh = await popAndPushScreen(
              context,
              screen: AppSettingsScreen(),
            );

            if (shouldRefresh != null) refresh();
          },
          message: 'Settings',
          icon: ezIcon(PlatformIcons(context).settings),
        ),
        Container(height: buttonSpacer),

        // Show input rules
        EZButton(
          action: () => ezDialog(
            context,
            title: 'Input rules',
            content: [
              Text(
                validatorRule,
                style: getTextStyle(dialogContentStyleKey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          body: Text('Input rules'),
        ),
        Container(height: buttonSpacer),

        // Reload
        EZButton.icon(
          action: () {
            popScreen(context, pass: true);
            reload();
          },
          message: 'Reload',
          icon: ezIcon(PlatformIcons(context).refresh),
        ),
      ],

      fab: EZButton(
        action: () async {
          dynamic shouldReload = await pushScreen(
            context,
            screen: CreateSignalScreen(),
          );

          if (shouldReload != null) reload();
        },
        body: ezIcon(PlatformIcons(context).add),
      ),
    );
  }
}
