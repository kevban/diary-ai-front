import 'package:diary_ai/helpers.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/widgets/shared/char_avatar.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/classes/message.dart';
import 'package:provider/provider.dart';

import '../../classes/character.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final Widget? bottom;

  const MessageTile({required this.message, this.bottom});

  @override
  Widget build(BuildContext context) {
    Character? character =
    context.read<CharacterProvider>().findCharacterByName(message.sender);
    Widget avatar;
    if (message.sender == 'Me') {
      avatar = const CharacterAvatar(
        name: 'Me',
        size: 48,
        color: Colors.teal,
      );
    } else if (character != null) {
      avatar = CharacterAvatar(
        name: character!.name,
        size: 48,
        color: Colors.brown,
        image: character.getImage(),
      );
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
                  color: message.sender == 'Me'
                      ? Colors.grey[400]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(message.sender,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    )),
                SizedBox(height: 4),
                Text(
                  message.text,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: null,
                ),
                (bottom != null) ? bottom! : Container()
            ],
          )),
    )],
    )
    ,
    );
  }
}
