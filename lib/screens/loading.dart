import '../utils/utils.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late double buttonSpacer = EzConfig.prefs[buttonSpacingKey];

  @override
  Widget build(BuildContext context) {
    return EzScaffold(
      backgroundDecoration: BoxDecoration(color: Color(EzConfig.prefs[backColorKey])),
      appBar: EzAppBar(
        title: Text(
          appTitle,
          style: getTextStyle(titleStyleKey),
        ),
      ),
      body: standardWindow(
        context: context,
        backgroundImage: buildDecoration(backImageKey),
        body: loadingMessage(
          context: context,
          image: ezImage(pathKey: signalImageKey),
        ),
      ),
    );
  }
}
