import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../utils/material-ui.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import '../signals/signal.dart';
import '../signals/signal-api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignalBoard extends StatefulWidget {
  const SignalBoard({Key? key}) : super(key: key);

  @override
  _SignalBoardState createState() => _SignalBoardState();
}

class _SignalBoardState extends State<SignalBoard> {
  late Stream<QuerySnapshot<Object?>> _signalStream;
  late Stream<QuerySnapshot<Object?>> _requestStream;

  @override
  void initState() {
    super.initState();
    _signalStream = streamSignals(membersPath);
    _requestStream = streamSignals(memberReqsPath);
  }

  @override
  Widget build(BuildContext context) {
    return standardScaffold(
      context,

      // Title
      'Signals',

      // Body
      ezCenterScroll(
        [
          // Signals the user is a member of
          StreamBuilder<QuerySnapshot>(
              stream: _signalStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return loadingMessage(
                      context,
                      buildImage(
                        AppConfig.prefs[signalImageKey],
                        isAssetImage(AppConfig.prefs[signalImageKey]),
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
      ),

      // Background image/decoration
      buildDecoration(AppConfig.prefs[backImageKey]),

      // Fallback background color
      Color(AppConfig.prefs[signalsBackgroundColorKey]),

      // Android config
      MaterialScaffoldData(
        endDrawer: signalBoardDrawer(context),
        floatingActionButton: ezButton(
          // Refresh
          () => setState(() {}),
          // Reload
          () => setState(() {
            _signalStream = streamSignals(membersPath);
            _requestStream = streamSignals(memberReqsPath);
          }),
          Icon(Icons.refresh),
          ElevatedButton.styleFrom(
            backgroundColor: Color(AppConfig.prefs[buttonColorKey]),
            foregroundColor: Color(AppConfig.prefs[buttonTextColorKey]),
            padding: EdgeInsets.all(AppConfig.prefs[paddingKey]),
            shape: CircleBorder(),
          ),
        ),
      ),

      // iOS config
      CupertinoPageScaffoldData(),
    );
  }
}
