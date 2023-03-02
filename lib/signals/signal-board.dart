import '../utils/storage.dart';
import '../utils/scaffolds.dart';
import '../user/user-api.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import '../utils/custom-widgets.dart';
import '../signals/signal.dart';
import '../signals/signal-api.dart';

import 'package:flutter/material.dart';
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
    return signalBoardScaffold(
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
                    return loadingMessage(context);
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

      // Floating action tap: refresh
      () => setState(() {}),

      // Floating action on long press: reload
      () => setState(() {
        _signalStream = streamSignals(membersPath);
        _requestStream = streamSignals(memberReqsPath);
      }),

      // Background image/decoration
      buildDecoration(AppUser.prefs[signalsImageKey]),

      // Fallback background color
      Color(AppUser.prefs[signalsBackgroundColorKey]),
    );
  }
}
