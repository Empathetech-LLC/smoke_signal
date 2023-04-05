import 'create-signal.dart';
import 'app-settings.dart';
import '../utils/signal.dart';
import '../utils/drawers.dart';
import '../utils/constants.dart';

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
  double buttonSpacer = AppConfig.prefs[buttonSpacingKey];

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
    return EZScaffold(
      // Title && theme
      title: 'Signals',
      backgroundImage: buildDecoration(AppConfig.prefs[backImageKey]),
      backgroundColor: Color(AppConfig.prefs[backColorKey]),

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
                      image: buildImage(pathKey: signalImageKey),
                    );
                  case ConnectionState.done:
                  default:
                    if (snapshot.hasError) {
                      popNLog(context, snapshot.error.toString());
                      return Container();
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: snapshot.data!.docs
                          .map((DocumentSnapshot signalDoc) =>
                              Signal.buildSignal(signalDoc, refresh, reload))
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
                      popNLog(context, snapshot.error.toString());
                      return Container();
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: snapshot.data!.docs
                          .map((DocumentSnapshot signalDoc) =>
                              Signal.buildSignal(signalDoc, refresh, reload))
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
            bool shouldRefresh = await popAndPushScreen(
              context,
              screen: AppSettingsScreen(),
            );

            if (shouldRefresh) refresh();
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
            popScreen(context);
            reload();
          },
          message: 'Reload',
          icon: ezIcon(PlatformIcons(context).refresh),
        ),
      ],

      fab: EZButton(
        action: () async {
          bool shouldReload = await pushScreen(
            context,
            screen: CreateSignalScreen(),
          );

          if (shouldReload) reload();
        },
        body: ezIcon(PlatformIcons(context).add),
      ),
    );
  }
}
