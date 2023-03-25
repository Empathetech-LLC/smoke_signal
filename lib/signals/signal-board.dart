import '../app/settings-screen.dart';
import '../utils/drawers.dart';
import '../utils/constants.dart';
import '../utils/validate.dart';
import '../signals/signal.dart';
import '../signals/signal-api.dart';
import '../signals/create-signal-screen.dart';
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
    return ezScaffold(
      context: context,

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
                      context: context,
                      image: buildImage(
                        path: AppConfig.prefs[signalImageKey],
                      ),
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
                              Signal.buildSignal(signalDoc))
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
                              Signal.buildSignal(signalDoc))
                          .toList(),
                    );
                }
              }),
        ],
        centered: true,
      ),

      // User interaction
      drawerHeader: signalDrawerHeader(context),
      drawerBody: [
        Container(height: buttonSpacer),

        // Add new signal
        EZButton.icon(
          action: () async {
            bool shouldReload = await popAndPushScreen(
              context: context,
              screen: CreateSignalScreen(),
            );

            if (shouldReload) reload();
          },
          message: 'New signal',
          icon: ezIcon(PlatformIcons(context).add),
        ),
        Container(height: buttonSpacer),

        // GoTo settings
        EZButton.icon(
          action: () => popAndPushScreen(
            context: context,
            screen: SettingsScreen(startIndex: 1),
          ),
          message: 'Settings',
          icon: ezIcon(PlatformIcons(context).settings),
        ),
        Container(height: buttonSpacer),

        // Show input rules
        EZButton(
          action: () => ezDialog(
            context: context,
            title: 'Input rules',
            content: Text(
              validatorRule,
              style: getTextStyle(dialogContentStyleKey),
              textAlign: TextAlign.center,
            ),
          ),
          body: Text('Input rules'),
        ),
        Container(height: buttonSpacer),
      ],

      fab: EZButton(
        action: refresh,
        longAction: reload,
        body: ezIcon(PlatformIcons(context).refresh),
        customStyle: ElevatedButton.styleFrom(shape: CircleBorder()),
      ),
    );
  }
}
