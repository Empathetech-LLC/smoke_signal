import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/validate.dart';
import '../user/user-api.dart';
import '../signals/signal-api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CreateSignalScreen extends StatefulWidget {
  const CreateSignalScreen({Key? key}) : super(key: key);

  @override
  _CreateSignalScreenState createState() => _CreateSignalScreenState();
}

class _CreateSignalScreenState extends State<CreateSignalScreen> {
  // Initialize state

  late Stream<QuerySnapshot<Map<String, dynamic>>> _userStream;

  @override
  void initState() {
    super.initState();
    _userStream = streamUsers();
  }

  late bool isActive = false;
  late List<String> requestIDs = [];

  final titleFormKey = GlobalKey<FormState>();
  final messageFormKey = GlobalKey<FormState>();

  late TextEditingController _titleController = TextEditingController();
  late TextEditingController _messageController = TextEditingController();

  // Gather theme data
  late double buttonSpacer = AppConfig.prefs[buttonSpacingKey];
  late double dialogSpacer = AppConfig.prefs[dialogSpacingKey];

  late Color themeTextColor = Color(AppConfig.prefs[themeTextColorKey]);
  late Color buttonColor = Color(AppConfig.prefs[buttonColorKey]);
  late Color buttonTextColor = Color(AppConfig.prefs[buttonTextColorKey]);

  // Creates the widgets for the toggle list from the gathered profiles
  List<Widget> buildSwitches(List<UserProfile> profiles) {
    List<Widget> children = [];

    profiles.forEach((profile) {
      if (profile.id != AppUser.account.uid)
        children.addAll(
          [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Switch
                ezSwitch(
                  context,
                  requestIDs.contains(profile.id),
                  (bool? value) {
                    if (value == true) {
                      setState(() {
                        requestIDs.add(profile.id);
                      });
                    } else {
                      setState(() {
                        requestIDs.remove(profile.id);
                      });
                    }
                  },
                ),

                // Profile image/avatar
                CircleAvatar(
                  foregroundImage: CachedNetworkImageProvider(profile.avatarURL),
                  minRadius: 35,
                  maxRadius: 35,
                ),

                // Display name
                paddedText(
                  profile.name,
                  getTextStyle(dialogTitleStyleKey),
                  TextAlign.start,
                ),
              ],
            ),
            Container(height: dialogSpacer),
          ],
        );
    });

    return children;
  }

  // Draw state

  @override
  Widget build(BuildContext context) {
    return ezScaffold(
      context,

      // Title
      'New signal',

      // Body
      ezCenterScroll(
        [
          // Title field
          ezForm(
            titleFormKey,
            _titleController,
            'Signal title',
            false,
            null,
            signalTitleValidator,
            AutovalidateMode.onUserInteraction,
          ),
          Container(height: buttonSpacer),

          // Message field
          ezForm(
            messageFormKey,
            _messageController,
            'Notification',
            false,
            null,
            signalMessageValidator,
            AutovalidateMode.onUserInteraction,
          ),
          Container(height: buttonSpacer),

          // Toggle for current participation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Currently active?',
                style: getTextStyle(dialogTitleStyleKey),
              ),
              ezSwitch(
                context,
                isActive,
                (bool? value) {
                  // Flip state and close keyboard if open
                  AppConfig.focus.primaryFocus?.unfocus();

                  setState(() {
                    isActive = value!;
                  });
                },
              ),
            ],
          ),
          Container(height: buttonSpacer),

          // List of toggle-able members to send join requests on creation
          ezList(
            'Starting members',
            [
              StreamBuilder<QuerySnapshot>(
                stream: _userStream,
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

                      return ezCenterScroll(
                        buildSwitches(buildProfiles(snapshot.data!.docs)),
                      );
                  }
                },
              ),
            ],
          ),
          Container(height: buttonSpacer),

          // Add button
          ezIconButton(
            () async {
              // Close keyboard if open
              AppConfig.focus.primaryFocus?.unfocus();

              // Don't do anything if the input is invalid
              if (!titleFormKey.currentState!.validate()) {
                popNLog(context, 'Invalid title!');
                return;
              } else if (!messageFormKey.currentState!.validate()) {
                popNLog(context, 'Invalid message!');
                return;
              }

              // Attempt adding signal
              await addtoDB(
                context,
                _titleController.text.trim(),
                _messageController.text.trim(),
                isActive,
                requestIDs,
              );

              Navigator.of(context).pop();
            },
            'Done',
            PlatformIcons(context).cloudUpload,
          ),
          Container(height: buttonSpacer),
        ],
      ),

      // Background image/decoration
      buildDecoration(AppConfig.prefs[backImageKey]),

      // Fallback background color
      Color(AppConfig.prefs[backColorKey]),

      // Android config
      MaterialScaffoldData(),

      // iOS config
      CupertinoPageScaffoldData(),
    );
  }
}
