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

  late double buttonSpacer = EzConfig.prefs[buttonSpacingKey];
  late double dialogSpacer = EzConfig.prefs[dialogSpacingKey];

  late Color themeTextColor = Color(EzConfig.prefs[themeTextColorKey]);
  late Color buttonColor = Color(EzConfig.prefs[buttonColorKey]);
  late Color buttonTextColor = Color(EzConfig.prefs[buttonTextColorKey]);

  /// Creates a [List] of [PlatformListTile]s for displaying [UserProfile]s alongside
  List<PlatformListTile> buildSwitches(List<UserProfile> profiles) {
    List<PlatformListTile> children = [];

    profiles.forEach((profile) {
      if (profile.id != AppUser.account.uid)
        children.add(
          PlatformListTile(
            // User info
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile image/avatar
                CircleAvatar(
                  foregroundImage: CachedNetworkImageProvider(profile.avatarURL),
                  minRadius: 35,
                  maxRadius: 35,
                ),
                Container(width: EzConfig.prefs[paddingKey]),

                // Display name
                EzText.simple(
                  profile.name,
                  style: buildTextStyle(styleKey: dialogTitleStyleKey),
                  textAlign: TextAlign.start,
                ),
              ],
            ),

            // Toggle
            trailing: EzCheckBox(
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
          ),
        );
    });

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return EzScaffold(
      background: BoxDecoration(color: Color(EzConfig.prefs[backColorKey])),
      appBar: EzAppBar(
          title: EzText.simple('New signal',
              style: buildTextStyle(styleKey: titleStyleKey))),

      // Body
      body: standardView(
        context: context,
        background: BoxDecoration(
          image: DecorationImage(image: EzImage.getProvider(backImageKey)),
        ),
        body: EzScrollView(
          children: [
            // Title field
            EzFormField(
              key: titleFormKey,
              controller: _titleController,
              hintText: 'Signal title',
              validator: signalTitleValidator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            Container(height: buttonSpacer),

            // Message field
            EzFormField(
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
                EzText.simple(
                  'Currently active?',
                  style: buildTextStyle(styleKey: dialogTitleStyleKey),
                ),
                EzSwitch(
                  value: isActive,
                  onChanged: (bool? value) {
                    // Flip state and close keyboard if open
                    closeFocus();

                    setState(() {
                      isActive = value!;
                    });
                  },
                ),
              ],
            ),
            Container(height: buttonSpacer),

            // List of toggle-able members to send join requests on creation
            StreamBuilder<QuerySnapshot>(
              stream: _userStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return loadingMessage(
                      context: context,
                      image: EzImage(prefsKey: signalImageKey),
                    );
                  case ConnectionState.done:
                  default:
                    if (snapshot.hasError) {
                      logAlert(context, snapshot.error.toString());
                      return Container();
                    }

                    return addProfilesWindow(
                      context: context,
                      title: 'Starting members',
                      items: buildSwitches(buildProfiles(snapshot.data!.docs)),
                    );
                }
              },
            ),
            Container(height: buttonSpacer),

            // Add button
            EzButton.icon(
              action: () async {
                // Close keyboard if open
                closeFocus();

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

                if (added) popScreen(context: context, pass: true);
              },
              message: 'Add',
              icon: EzIcon(PlatformIcons(context).cloudUpload),
            ),
            Container(height: buttonSpacer),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
