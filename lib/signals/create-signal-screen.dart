import '../utils/storage.dart';
import '../utils/scaffolds.dart';
import '../utils/custom-widgets.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/text.dart';
import '../user/user-api.dart';
import '../signals/signal-api.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CreateSignalScreen extends StatefulWidget {
  const CreateSignalScreen({Key? key}) : super(key: key);

  @override
  _CreateSignalScreenState createState() => _CreateSignalScreenState();
}

class _CreateSignalScreenState extends State<CreateSignalScreen> {
  //// Initialize state

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
  late double buttonSpacer = AppUser.prefs[buttonSpacingKey];
  late double dialogSpacer = AppUser.prefs[dialogSpacingKey];

  late Color themeTextColor = Color(AppUser.prefs[themeTextColorKey]);
  late Color buttonColor = Color(AppUser.prefs[buttonColorKey]);
  late Color buttonTextColor = Color(AppUser.prefs[buttonTextColorKey]);

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
                // Check box
                Checkbox(
                  value: requestIDs.contains(profile.id),
                  onChanged: (bool? value) {
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
                  fillColor: MaterialStateProperty.all(buttonColor),
                  checkColor: buttonTextColor,
                  activeColor: buttonColor,
                ),

                // Profile image/avatar
                CircleAvatar(
                  backgroundImage: AssetImage(loadingGifPath),
                  foregroundImage: CachedNetworkImageProvider(profile.avatarURL),
                  minRadius: 35,
                  maxRadius: 35,
                ),

                // Display name
                paddedText(profile.name, dialogTitleStyle, TextAlign.start),
              ],
            ),
            Container(height: dialogSpacer),
          ],
        );
    });

    return children;
  }

  //// Draw state

  @override
  Widget build(BuildContext context) {
    return standardScaffold(
      context,

      // Title
      'New signal',

      // Body
      ezCenterScroll(
        [
          // Title field
          Form(
            key: titleFormKey,
            child: OutlinedButton(
              style: textFieldStyle(),
              onPressed: () {},
              child: TextFormField(
                cursorColor: themeTextColor,
                controller: _titleController,
                textAlign: TextAlign.center,
                style: getTextStyle(dialogContentStyle),
                decoration: InputDecoration(
                  hintText: 'Signal title',
                  border: blankBorder(),
                  focusedBorder: blankBorder(),
                ),
                validator: signalTitleValidator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
          ),
          Container(height: buttonSpacer),

          // Message field
          Form(
            key: messageFormKey,
            child: OutlinedButton(
              style: textFieldStyle(),
              onPressed: () {},
              child: TextFormField(
                cursorColor: themeTextColor,
                controller: _messageController,
                textAlign: TextAlign.center,
                style: getTextStyle(dialogContentStyle),
                decoration: InputDecoration(
                  hintText: 'Notification message',
                  border: blankBorder(),
                  focusedBorder: blankBorder(),
                ),
                validator: signalMessageValidator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
          ),
          Container(height: buttonSpacer),

          // Toggle for current participation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Currently active?',
                style: getTextStyle(dialogTitleStyle),
              ),
              Checkbox(
                value: isActive,
                onChanged: (bool? value) {
                  // Flip state and close keyboard if open
                  AppUser.focus.primaryFocus?.unfocus();

                  setState(() {
                    isActive = value!;
                  });
                },
                fillColor: MaterialStateProperty.all(buttonColor),
                checkColor: buttonTextColor,
                activeColor: buttonColor,
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
                      return loadingMessage(context);
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
              AppUser.focus.primaryFocus?.unfocus();

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
            () {},
            Icon(Icons.upload),
            Text('Done'),
          ),
          Container(height: buttonSpacer),
        ],
      ),

      // Background image/decoration
      buildDecoration(AppUser.prefs[backImageKey]),

      // Fallback background color
      Color(AppUser.prefs[signalsBackgroundColorKey]),

      // Drawer aka settings hamburger
      null,
    );
  }
}
