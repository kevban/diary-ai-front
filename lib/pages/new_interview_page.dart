import 'package:diary_ai/app_data.dart';
import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/interview.dart';
import 'package:diary_ai/classes/scenario.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/providers/message_provider.dart';
import 'package:diary_ai/providers/scenario_provider.dart';
import 'package:diary_ai/theme.dart';
import 'package:diary_ai/widgets/char_widgets/character_tile.dart';
import 'package:diary_ai/widgets/setting_widgets/topics_field.dart';
import 'package:diary_ai/widgets/shared/char_avatar.dart';
import 'package:diary_ai/widgets/shared/char_list.dart';
import 'package:diary_ai/widgets/shared/my_scaffold.dart';
import 'package:diary_ai/widgets/shared/scenario_grid.dart';
import 'package:diary_ai/widgets/shared/scenario_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class NewInterviewPage extends StatefulWidget {
  const NewInterviewPage({Key? key}) : super(key: key);

  @override
  State<NewInterviewPage> createState() => _NewInterviewPageState();
}

class _NewInterviewPageState extends State<NewInterviewPage> {
  int _index = 0;
  Character? _selectedChar;
  Scenario? _selectedScenario;
  GlobalKey _charList = GlobalKey();
  GlobalKey _sceneList = GlobalKey();
  TextEditingController _titleInputController = TextEditingController();

  void _handleSubmit(BuildContext context) {
    if (_selectedChar != null && _selectedScenario != null) {
      Interview newInterview = context.read<MessageProvider>().addInterview(
          characterId: _selectedChar!.id,
          scenarioId: _selectedScenario!.id,
          title: _titleInputController.text);
      context.go('/interview/${newInterview.id}');
    }
  }

  void setChatTitle() {
    final title =
        _selectedScenario != null ? '${_selectedScenario!.title} w/ ' : '';
    final name = _selectedChar != null ? _selectedChar!.name : '';
    _titleInputController.text = '$title$name';
  }


  @override
  Widget build(BuildContext context) {

    return MyScaffold(
        appbarTitle: 'New Chat',
        body: Stepper(
          type: StepperType.horizontal,
          elevation: 0,
          currentStep: _index,
          controlsBuilder: (context, details) {
            if (_index <= 0) {
              return Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: Text('Continue'))
                  ],
                ),
              );
            } else if (_index >= 2) {
              return Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () => _handleSubmit(context),
                        child: Text('Finish')),
                    const SizedBox(
                      width: spacingLarge,
                    ),
                    ElevatedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back')),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: Text('Continue')),
                    const SizedBox(
                      width: spacingLarge,
                    ),
                    ElevatedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back')),
                  ],
                ),
              );
            }
          },
          onStepCancel: () {
            if (_index > 0) {
              setState(() {
                _index -= 1;
              });
            }
          },
          onStepContinue: () {
            if (_index <= 1) {
              setState(() {
                _index += 1;
              });
            }
          },
          onStepTapped: (step) {
            setState(() {
              _index = step;
            });
          },
          steps: [
            Step(
                title: Text('Character'),
                content: Column(
                  children: [
                    Text(
                      'You will be chatting with:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(
                      height: spacingLarge,
                    ),
                    Center(
                      child: Column(
                        children: [
                          Container(
                              height: 400,
                              child: CharList(
                                select: (Character character) {
                                  setState(() {
                                    _selectedChar = character;
                                    setChatTitle();
                                  });
                                },
                                selectedId: _selectedChar == null
                                    ? null
                                    : _selectedChar!.id,
                                mode: 'select',
                              ))
                        ],
                      ),
                    ),
                  ],
                )),
            Step(
                title: Text('Scenario'),
                content: Column(
                  children: [
                    Text(
                      'Choose a scenario for your conversation with ${_selectedChar != null ? _selectedChar!.name : 'your character'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(
                      height: spacingLarge,
                    ),
                    Container(
                        height: 400,
                        child: ScenarioGrid(
                          mode: 'select',
                          selectedId: _selectedScenario == null
                              ? null
                              : _selectedScenario!.id,
                          select: (Scenario scenario) {
                            setState(() {
                              _selectedScenario = scenario;
                              setChatTitle();
                            });
                          },
                        ))
                  ],
                )),
            Step(
                title: Text('Finish'),
                content: Column(
                  children: [
                    Text(
                      'Interview Settings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(
                      height: spacingLarge,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'e.g. Daily Journaling with AI',
                        labelText: 'Interview Title',
                      ),
                      controller: _titleInputController,
                    )
                  ],
                ))
          ],
        ));
  }
}
