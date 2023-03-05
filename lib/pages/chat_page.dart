import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/interview.dart';
import 'package:diary_ai/classes/message.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/providers/message_provider.dart';
import 'package:diary_ai/widgets/shared/my_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/widgets/chat_widgets/new_message_form.dart';
import 'package:diary_ai/widgets/chat_widgets/message_list.dart';
import 'package:diary_ai/config.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  String interviewTitle;

  ChatPage({Key? key, required this.interviewTitle}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    MessageProvider messageProvider = context.watch<MessageProvider>();
    CharacterProvider characterProvider = context.watch<CharacterProvider>();
    Interview? interview =
        messageProvider.getInterviewByTitle(widget.interviewTitle);
    Character? character = interview == null
        ? null
        : characterProvider.findCharacterByName(interview.characterName);
    return MyScaffold(
      appbarTitle: 'Chat',
      body: Column(
        children: [
          Expanded(
              child: MessageList(
            interview: interview,
          )),
          NewMessageForm(
              send: character == null ? null : (newMsg) => messageProvider.userMsg(
                    newMsg: newMsg,
                    interviewTitle: widget.interviewTitle,
                    character: character,
                  )),
        ],
      ),
    );
  }
}
