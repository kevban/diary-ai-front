import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/interview.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/providers/scenario_provider.dart';
import 'package:diary_ai/providers/message_provider.dart';
import 'package:diary_ai/theme.dart';
import 'package:diary_ai/widgets/chat_widgets/notice_message.dart';
import 'package:diary_ai/widgets/chat_widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/widgets/chat_widgets/message_tile.dart';
import 'package:diary_ai/classes/message.dart';
import 'package:provider/provider.dart';

import '../../classes/scenario.dart';

class MessageList extends StatefulWidget {
  Interview interview;
  Character? character;
  Scenario? scenario;

  MessageList(
      {Key? key,
      required this.interview,
      required this.character,
      required this.scenario})
      : super(key: key);

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<Widget> messageTiles = [];
    List<Message> messages = widget.interview.getMessages();
    if (widget.interview.status == 'STANDBY') {
      if (widget.character != null && widget.scenario != null) {
        context.read<MessageProvider>().userMsg(
            interview: widget.interview,
            character: widget.character!,
            scenario: widget.scenario!);
      }
    }
    for (Message message in messages) {
      messageTiles.add(MessageTile(
        message: message,
        characterId: widget.interview!.characterId,
      ));
    }
    switch (widget.interview!.status) {
      case 'STANDBY':
        messageTiles.add(NoticeMessage(
            content: Text('${widget.character!.name} is ready to chat.')));
        break;
      case 'ENDED':
        messageTiles.add(
            NoticeMessage(content: TypingIndicator(text: 'Generating diary ')));
        break;
      case 'TYPING':
        messageTiles.add(NoticeMessage(
            content:
                TypingIndicator(text: '${widget.character!.name} is typing ')));
        break;
      default:
        break;
    }
    if (widget.character == null || widget.scenario == null) {
      messageTiles.add(Center(
        child: Text('Error: Scenario/character not found!'),
      ));
    }
    Widget listView = ListView(
      controller: _scrollController,
      reverse: true,
      children: messageTiles.reversed.toList(),
    );
    return listView;
  }
}
