import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/pages/chat_page.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/providers/message_provider.dart';
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
    return MyScaffold(
      appbarTitle: 'Interviews',
      body: ListView(
        children: messageProvider.interviews.map((interview) {
          Character? character =
              characterProvider.findCharacterByName(interview.characterName);
          return ListTile(
            leading: CharacterAvatar(
              name: interview.characterName!,
              image: character?.getImage(),
              size: 82,
            ),
            title: Text(interview.title),
            subtitle: Text(character == null ? '' : character.name),
            onTap: () => context.go('/interview/${interview.title}')
          );
        }).toList(),
      ),
    );
  }
}
