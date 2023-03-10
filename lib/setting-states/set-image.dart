import '../utils/constants.dart';
import '../utils/text.dart';
import '../utils/custom-widgets.dart';
import '../user/user-api.dart';
import '../utils/storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ImageSetting extends StatefulWidget {
  const ImageSetting({
    Key? key,
    required this.prefsKey,
    required this.message,
  }) : super(key: key);

  final String prefsKey;
  final String message;

  @override
  _ImageSettingState createState() => _ImageSettingState();
}

class _ImageSettingState extends State<ImageSetting> {
  //// Initialize state

  // Gather theme data
  late double buttonSpacer = AppUser.prefs[buttonSpacingKey];
  late double dialogSpacer = AppUser.prefs[dialogSpacingKey];

  late String currPath = widget.prefsKey;

  //// Define interaction methods

  // Top-level button onPressed: display the image source/update options
  void chooseImage() {
    ezDialog(
      context,

      // Title
      'Update background',

      // Body
      [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // From file
            ezIconButton(
              () async {
                bool attempt = await changeImage(
                  context,
                  widget.prefsKey,
                  ImageSource.gallery,
                );

                if (attempt) {
                  setState(() {
                    currPath = loadingGifPath;
                  });
                }
                Navigator.of(context).pop();
              },
              () {},
              Icon(Icons.file_open),
              PlatformText('File'),
            ),
            Container(height: buttonSpacer),

            // From camera
            ezIconButton(
              () async {
                bool attempt = await changeImage(
                  context,
                  widget.prefsKey,
                  ImageSource.camera,
                );

                if (attempt) {
                  setState(() {
                    currPath = loadingGifPath;
                  });
                }
                Navigator.of(context).pop();
              },
              () {},
              Icon(Icons.camera_alt),
              PlatformText('Camera'),
            ),
            Container(height: buttonSpacer),

            // Reset
            ezIconButton(
              () {
                AppUser.preferences.remove(widget.prefsKey);
                setState(() {
                  currPath = appDefaults[widget.prefsKey];
                });
                Navigator.of(context).pop();
              },
              () {},
              Icon(Icons.restore),
              PlatformText('Reset'),
            ),
            Container(height: buttonSpacer),

            // Clear
            ezIconButton(
              () {
                AppUser.preferences.setString(widget.prefsKey, noneIconPath);
                setState(() {
                  currPath = noneIconPath;
                });
                Navigator.of(context).pop();
              },
              () {},
              Icon(Icons.clear),
              PlatformText('Clear'),
            ),
            Container(height: buttonSpacer),
          ],
        ),
      ],
    );
  }

  // Top level on long press: pop-up displaying the stored credits for that image
  void rollCredits() {
    ezDialog(
      context,
      'Credit to:',
      [
        SelectableText(
          credits[widget.prefsKey] ?? 'Wherever you got this from!',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ezButton(
      chooseImage,
      rollCredits,
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PlatformText(widget.message, style: getTextStyle(imageSettingStyle)),
          SizedBox(
            height: widget.prefsKey == signalImageKey
                ? AppUser.prefs[signalCountHeightKey]
                : 160,
            width: widget.prefsKey == signalImageKey
                ? AppUser.prefs[signalCountHeightKey]
                : 90,
            child: buildImage(AppUser.prefs[widget.prefsKey], BoxFit.fill),
          ),
        ],
      ),
    );
  }
}
