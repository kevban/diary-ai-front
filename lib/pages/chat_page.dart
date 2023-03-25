import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/interview.dart';
import 'package:diary_ai/classes/message.dart';
import 'package:diary_ai/classes/scenario.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/pages/not_found_page.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/providers/message_provider.dart';
import 'package:diary_ai/providers/scenario_provider.dart';
import 'package:diary_ai/widgets/shared/my_scaffold.dart';
import 'package:diary_ai/widgets/shared/no_more_tokens_dialog.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/widgets/chat_widgets/new_message_form.dart';
import 'package:diary_ai/widgets/chat_widgets/message_list.dart';
import 'package:diary_ai/config.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  String interviewId;

  ChatPage({Key? key, required this.interviewId}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool broken = false;

  @override
  Widget build(BuildContext context) {
    MessageProvider messageProvider = context.watch<MessageProvider>();
    CharacterProvider characterProvider = context.read<CharacterProvider>();
    ScenarioProvider scenarioProvider = context.read<ScenarioProvider>();
    Interview? interview = messageProvider.getInterviewById(widget.interviewId);
    Character? character = interview == null
        ? null
        : characterProvider.getCharacterById(interview.characterId);
    Scenario? scenario = interview == null
        ? null
        : scenarioProvider.getScenarioById(id: interview.scenarioId);
    if (character == null || scenario == null) {
      broken = true;
    }
    if (interview == null) {
      return const NotFoundPage();
    } else {
      return MyScaffold(
        appbarTitle: interview.title,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: broken ? false : true,
                child: Text('Reset Chat'),
                value: 'reset',
              ),
              PopupMenuItem(
                child: Text('Delete Chat'),
                value: 'delete',
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'reset':
                  messageProvider.restartInterview(
                      interview: interview,
                      character: character!,
                      scenario: scenario!);
                  break;
                case 'delete':
                  messageProvider.removeInterviewById(id: interview.id);
                  context.go('/chat');
                  break;
              }
            },
          ),
        ],
        body: Column(
          children: [
            Expanded(
                child: MessageList(
              interview: interview,
              scenario: scenario,
              character: character,
            )),
            NewMessageForm(
              send: (newMsg) async {
                if (!broken) {
                  bool success = await messageProvider.userMsg(
                    newMsg: newMsg,
                    interview: interview,
                    character: character!,
                    scenario: scenario!,
                  );
                  if (!success) {
                    showDialog(
                        context: context,
                        builder: (context) => NoMoreTokensDialog());
                  }
                }
              },
              typing: interview.status == 'TYPING',
            ),
          ],
        ),
      );
    }
  }
}
