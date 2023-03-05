import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/interview.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/providers/content_provider.dart';
import 'package:diary_ai/providers/message_provider.dart';
import 'package:diary_ai/theme.dart';
import 'package:diary_ai/widgets/chat_widgets/notice_message.dart';
import 'package:diary_ai/widgets/chat_widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/widgets/chat_widgets/message_tile.dart';
import 'package:diary_ai/classes/message.dart';
import 'package:provider/provider.dart';

class MessageList extends StatefulWidget {
  Interview? interview;

  MessageList({Key? key, required this.interview}) : super(key: key);

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<Widget> messageTiles = [];
    if (widget.interview != null) {
      List<Message> messages = widget.interview!.getMessages();
      List<Message> currentMessages = widget.interview!.currentMessages;
      for (Message message in messages) {
        if (message.sender == 'System') {
          messageTiles.add(MessageTile(
            message: message,
            bottom: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.check,
                color: kSuccessColor,
              ),
              Text(
                'Saved Successfully!',
                style: TextStyle(color: kSuccessColor),
              ),
            ]),
          ));
        } else {
          messageTiles.add(MessageTile(message: message));
        }
      }
      switch (widget.interview!.status) {
        case 'STANDBY':
          messageTiles.add(NoticeMessage(
              content: Text(
                  '${widget.interview!.characterName} is ready for interview.')));
          break;
        case 'ENDED':
          messageTiles.add(NoticeMessage(
              content: TypingIndicator(text: 'Generating diary ')));
          break;
        case 'TYPING':
          messageTiles.add(NoticeMessage(
              content: TypingIndicator(
                  text: '${widget.interview!.characterName} is typing ')));
          break;
        default:
          break;
      }
    }
    Widget listView = ListView(
      controller: _scrollController,
      reverse: true,
      children: messageTiles.reversed.toList(),
    );
    return listView;
  }
}
