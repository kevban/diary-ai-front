import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/interview.dart';
import 'package:diary_ai/classes/scenario.dart';
import 'package:diary_ai/pages/chat_page.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/providers/message_provider.dart';
import 'package:diary_ai/providers/scenario_provider.dart';
import 'package:diary_ai/theme.dart';
import 'package:diary_ai/widgets/shared/char_avatar.dart';
import 'package:diary_ai/widgets/shared/my_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class InterviewPage extends StatefulWidget {
  const InterviewPage({Key? key}) : super(key: key);

  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage> {
  @override
  Widget build(BuildContext context) {
    MessageProvider messageProvider = context.watch<MessageProvider>();
    CharacterProvider characterProvider = context.watch<CharacterProvider>();
    messageProvider.interviews.sort((Interview a, Interview b) {
      return b.lastMessage.compareTo(a.lastMessage);
    });
    return MyScaffold(
      appbarTitle: 'My Chats',
      body: ListView(
        children: messageProvider.interviews.map((interview) {
          Character? character =
              characterProvider.getCharacterById(interview.characterId);
          return ListTile(
              leading: CharacterAvatar(
                character: character,
                size: avatarSmall,
              ),
              contentPadding: const EdgeInsets.all(16),
              style: ListTileStyle.drawer,
              title: Text(interview.title),
              subtitle: Text(
                interview.compileMessages(maxMsg: 1).trim(),
                maxLines: 1,
                style: const TextStyle(overflow: TextOverflow.ellipsis),
              ),
              trailing: Text(interview.getDate()),
              onTap: () => context.go('/interview/${interview.id}'));
        }).toList(),
      ),
    );
  }
}
