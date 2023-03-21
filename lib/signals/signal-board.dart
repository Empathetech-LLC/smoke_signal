import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../utils/drawers.dart';
import '../utils/constants.dart';
import '../signals/signal.dart';
import '../signals/signal-api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

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
    return ezScaffold(
      context: context,

      title: 'Signals',

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

      // Background image/decoration
      backgroundImage: buildDecoration(AppConfig.prefs[backImageKey]),

      // Fallback background color
      backgroundColor: Color(AppConfig.prefs[backColorKey]),

      // Scaffold config
      scaffoldConfig: MaterialScaffoldData(
        endDrawer: signalBoardDrawer(context),
        floatingActionButton: ezButton(
          // Refresh
          action: () => setState(() {}),
          // Reload
          longAction: () => setState(() {
            _signalStream = streamSignals(membersPath);
            _requestStream = streamSignals(memberReqsPath);
          }),
          body: Icon(PlatformIcons(context).refresh),
          customStyle: ElevatedButton.styleFrom(shape: CircleBorder()),
        ),
      ),
    );
  }
}
