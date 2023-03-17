import 'constants.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Returns whether the passed path refers to one of the stored asset images
bool isAssetImage(String? path) {
  if (path == null || path == '') return false;

  final List<String> assetImages = [
    appIconPath,
    darkForestPath,
    smokeSignalPath,
  ];

  return assetImages.contains(path);
}

DecorationImage? buildDecoration(String? path) {
  return (path == null)
      ? null
      : DecorationImage(
          image: provideImage(path, isAssetImage(path)),
          fit: BoxFit.fill,
        );
}
