import 'package:diary_ai/helpers.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/theme.dart';
import 'package:diary_ai/widgets/shared/char_avatar.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/classes/message.dart';
import 'package:provider/provider.dart';

import '../../classes/character.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final String characterId;

  const MessageTile({required this.message, required this.characterId});

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = ElevatedButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss the dialog
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Network Error"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("This might be because:"),
          SizedBox(height: spacingSmall),
          Text("• You are not connected to internet"),
          Text("• Server is overloaded with requests"),
          Text("• The content violates the policies of the chatbot provider"),
          SizedBox(height: spacingSmall),
          Text("You can:"),
          SizedBox(height: spacingSmall),
          Text("• Try again later"),
          Text("• Try with another scenario or character"),
          Text("• Try another message"),
        ],
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Character? character =
        context.read<CharacterProvider>().getCharacterById(characterId);
    Widget avatar;

    Color? backgroundColor = Colors.grey[200];
    if (message.sender == 'Me') {
      avatar = const CharacterAvatar(
        user: true,
        size: avatarSmall,
        color: Colors.teal,
      );
      backgroundColor = Colors.grey[200];
    } else if (character != null && message.sender != 'System') {
      avatar = CharacterAvatar(
        character: character,
        size: avatarSmall,
      );
      backgroundColor = Colors.white;
    } else {
      // when sender is system
      avatar = Container();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Row(
        children: [
          avatar,
          Expanded(
            flex: 1,
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.sender,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.black),
                    ),
                    SizedBox(height: 4),
                    Text(
                      message.text,
                      style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.grey[700]),
                      maxLines: null,
                    ),
                    (message.sender == 'System')
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  showAlertDialog(context);
                                },
                                child: Text('Why is this?')),
                          )
                        : Container()
                  ],
                )),
          )
        ],
      ),
    );
  }
}
