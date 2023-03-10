import '../utils/custom-widgets.dart';
import '../user/user-api.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

////// Colors //////

// Show custom color picker dialog
void colorPicker(
    BuildContext context,
    Color startColor,
    void Function(Color chosenColor) onColorChange,
    void Function() apply,
    void Function() cancel) {
  double dialogSpacer = AppUser.prefs[dialogSpacingKey];

  ezDialog(
    context,
    'Pick a color!',
    [
      ezScrollView(
        [
          // Main event
          ColorPicker(
            pickerColor: startColor,
            onColorChanged: onColorChange,
          ),
          Container(height: dialogSpacer),

          // Apply
          ezIconButton(
            apply,
            () {},
            Icon(Icons.check),
            PlatformText('Done'),
          ),
          Container(height: dialogSpacer),

          // Cancel
          ezIconButton(
            cancel,
            () {},
            Icon(Icons.cancel),
            PlatformText('Cancel'),
          ),
          Container(height: dialogSpacer),
        ],
      ),
    ],
  );
}

////// Images //////

// Returns whether the passed path refers to one of the stored asset images
bool isAssetImage(String? path) {
  if (path == null || path == '') return false;

  final List<String> assetImages = [
    appIconPath,
    noneIconPath,
    darkForestPath,
    loadingGifPath,
    smokeSignalPath,
  ];

  return assetImages.contains(path);
}

// Returns an image from a path, handling the image type
Image buildImage(String path, [BoxFit? fit]) {
  if (isAssetImage(path)) {
    return Image(
      image: AssetImage(path),
      fit: fit,
    );
  } else {
    return Image(
      image: FileImage(File(path)),
      fit: fit,
    );
  }
}

// Ditto but returns an image provider
ImageProvider provideImage(String path) {
  if (isAssetImage(path)) {
    return AssetImage(path);
  } else {
    return FileImage(File(path));
  }
}

// Ditto but returns a decoration image
DecorationImage? buildDecoration(String? path) {
  if (path == null || path == noneIconPath) {
    return null;
  } else {
    return DecorationImage(
      image: provideImage(path),
      fit: BoxFit.fill,
    );
  }
}

// Saves the passed image to the passed path
Future<bool> changeImage(
    BuildContext context, String prefsPath, ImageSource source) async {
  // Load image picker and save the result
  try {
    XFile? picked = await ImagePicker().pickImage(source: source);
    if (picked == null) {
      popNLog(context, 'Failed to retrieve image');
      return false;
    }

    // Build path
    Directory directory = await getApplicationDocumentsDirectory();
    String imageName = basename(picked.path);
    final image = File('${directory.path}/$imageName');

    // Save new image
    File(picked.path).copy(image.path);
    AppUser.preferences.setString(prefsPath, image.path);
    return true;
  } on Exception catch (e) {
    String errorMsg = 'Failed to update image:\n$e';
    popNLog(context, errorMsg);
    return false;
  }
}
