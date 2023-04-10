import '../utils/utils.dart';

import 'package:empathetech_ss_api/empathetech_ss_api.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CreateSignalScreen extends StatefulWidget {
  const CreateSignalScreen({Key? key}) : super(key: key);

  @override
  _CreateSignalScreenState createState() => _CreateSignalScreenState();
}

class _CreateSignalScreenState extends State<CreateSignalScreen> {
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
                ezCheckBox(
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
                ),

                // Profile image/avatar
                CircleAvatar(
                  foregroundImage: CachedNetworkImageProvider(profile.avatarURL),
                  minRadius: 35,
                  maxRadius: 35,
                ),

                // Display name
                ezText(
                  profile.name,
                  style: getTextStyle(dialogTitleStyleKey),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            Container(height: dialogSpacer),
          ],
        );
    });

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return EZScaffold(
      // Title && theme
      title: Text('New signal', style: getTextStyle(titleStyleKey)),
      backgroundImage: buildDecoration(AppConfig.prefs[backImageKey]),
      backgroundColor: Color(AppConfig.prefs[backColorKey]),

      // Body
      body: ezScrollView(
        children: [
          // Title field
          ezForm(
            key: titleFormKey,
            controller: _titleController,
            hintText: 'Signal title',
            validator: signalTitleValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          Container(height: buttonSpacer),

          // Message field
          ezForm(
            key: messageFormKey,
            controller: _messageController,
            hintText: 'Notification',
            validator: signalMessageValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                value: isActive,
                onChanged: (bool? value) {
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
            context,
            title: 'Starting members',
            items: [
              StreamBuilder<QuerySnapshot>(
                stream: _userStream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return loadingMessage(
                        context,
                        image: ezImage(pathKey: signalImageKey),
                      );
                    case ConnectionState.done:
                    default:
                      if (snapshot.hasError) {
                        logAlert(context, snapshot.error.toString());
                        return Container();
                      }

                      return ezScrollView(
                        children: buildSwitches(buildProfiles(snapshot.data!.docs)),
                        centered: true,
                      );
                  }
                },
              ),
            ],
          ),
          Container(height: buttonSpacer),

          // Add button
          EZButton.icon(
            action: () async {
              // Close keyboard if open
              AppConfig.focus.primaryFocus?.unfocus();

              // Don't do anything if the input is invalid
              if (!titleFormKey.currentState!.validate()) {
                logAlert(context, 'Invalid title!');
                return;
              } else if (!messageFormKey.currentState!.validate()) {
                logAlert(context, 'Invalid message!');
                return;
              }

              // Attempt adding signal
              bool added = await addToDB(
                context,
                _titleController.text.trim(),
                _messageController.text.trim(),
                isActive,
                requestIDs,
              );

              if (added) popScreen(context, pass: true);
            },
            message: 'Add',
            icon: ezIcon(PlatformIcons(context).cloudUpload),
          ),
          Container(height: buttonSpacer),
        ],
        centered: true,
      ),
    );
  }
}
