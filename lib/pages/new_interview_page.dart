import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/interview.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/providers/message_provider.dart';
import 'package:diary_ai/theme.dart';
import 'package:diary_ai/widgets/setting_widgets/topics_field.dart';
import 'package:diary_ai/widgets/shared/char_avatar.dart';
import 'package:diary_ai/widgets/shared/my_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NewInterviewPage extends StatefulWidget {
  const NewInterviewPage({Key? key}) : super(key: key);

  @override
  State<NewInterviewPage> createState() => _NewInterviewPageState();
}

class _NewInterviewPageState extends State<NewInterviewPage> {
  int _index = 0;
  Character? _selectedChar;
  List<String> _topics = ['My day', 'My mood', 'My plans for tomorrow'];
  TextEditingController _userNameInputController = TextEditingController();
  TextEditingController _userDescInputController = TextEditingController();
  TextEditingController _contentTypeInputController = TextEditingController();
  TextEditingController _contentPromptInputController = TextEditingController();
  TextEditingController _titleInputController = TextEditingController();

  String? _frequency;

  void _onTopicsChanged(List<String> value) {
    setState(() {
      _topics = value;
    });
  }

  void _handleSubmit(BuildContext context) {
    Interview interview = Interview(
        userName: _userNameInputController.text,
        userDesc: _userDescInputController.text,
        topics: _topics,
        contentStarter: _contentPromptInputController.text,
        contentType: _contentTypeInputController.text,
        title: _titleInputController.text,
        characterName: _selectedChar?.name);
    context.read<MessageProvider>().addInterview(interview);
  }

  @override
  Widget build(BuildContext context) {
    CharacterProvider characterProvider = context.watch<CharacterProvider>();
    return MyScaffold(
        appbarTitle: 'New Interview',
        body: Theme(
          data: appTheme,
          child: Stepper(
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
              } else if (_index >= 3) {
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ElevatedButton(
                          onPressed: details.onStepCancel, child: Text('Back')),
                      ElevatedButton(
                          onPressed: () => _handleSubmit(context),
                          child: Text('Finish'))
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
                        width: 10,
                      ),
                      ElevatedButton(
                          onPressed: details.onStepCancel, child: Text('Back')),
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
              if (_index <= 2) {
                setState(() {
                  _index += 1;
                });
              }
            },
            steps: [
              Step(
                  title: Text('Character'),
                  content: Column(
                    children: [
                      Text(
                        'This Character will be the interviewer:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: Column(
                          children: [
                            CharacterAvatar(
                              name: _selectedChar is Character
                                  ? _selectedChar!.name
                                  : 'AI',
                              size: 82,
                              image: _selectedChar is Character
                                  ? _selectedChar!.getImage()
                                  : null,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            DropdownButton(
                              items: [
                                DropdownMenuItem(
                                  child: Text('Random'),
                                  value: null,
                                ),
                                ...characterProvider.characters
                                    .map((character) => DropdownMenuItem(
                                          child: Text(character.name),
                                          value: character,
                                        ))
                              ],
                              menuMaxHeight: 400,
                              isExpanded: true,
                              onChanged: (selected) {
                                setState(() {
                                  _selectedChar = selected;
                                });
                              },
                              value: _selectedChar,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'The interviewee (you) is:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        decoration: InputDecoration(
                            hintText: 'e.g. John Doe', labelText: 'Your name'),
                        controller: _userNameInputController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        decoration: InputDecoration(
                            hintText: 'e.g. a stranger',
                            labelText: 'Your description'),
                        controller: _userDescInputController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  )),
              Step(
                  title: Text('Topics'),
                  content: Column(
                    children: [
                      Text(
                        '${_selectedChar == null ? 'A random Character' : _selectedChar!.name} will ask you about the following:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      CharacterAvatar(
                        name: _selectedChar is Character
                            ? _selectedChar!.name
                            : 'AI',
                        size: 82,
                        image: _selectedChar is Character
                            ? _selectedChar!.getImage()
                            : null,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TopicsField(
                        topics: _topics,
                        onChanged: _onTopicsChanged,
                      )
                    ],
                  )),
              Step(
                  title: Text('Content'),
                  content: Column(
                    children: [
                      Text(
                        'Based on your responses, AI will generate:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextField(
                        decoration: InputDecoration(hintText: 'e.g. Diary'),
                        controller: _contentTypeInputController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('that starts with:'),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        decoration:
                            InputDecoration(hintText: 'e.g. Dear diary,'),
                        controller: _contentPromptInputController,
                      )
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
                        height: 30,
                      ),
                      TextField(
                        decoration: InputDecoration(
                            hintText: 'e.g. Daily Journaling with AI',
                            labelText: 'Interview Title'),
                        controller: _titleInputController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      // Row(
                      //   children: [
                      //     Text('Recurring:'),
                      //     SizedBox(width: 10,),
                      //     DropdownButton(
                      //         items: [
                      //           DropdownMenuItem(
                      //             child: Text('One time'),
                      //             value: 'SINGLE',
                      //           ),
                      //           DropdownMenuItem(
                      //             child: Text('Everyday'),
                      //             value: 'DAILY',
                      //           ),
                      //           DropdownMenuItem(
                      //             child: Text('Every week'),
                      //             value: 'WEEKLY',
                      //           ),
                      //           DropdownMenuItem(
                      //             child: Text('Repeated'),
                      //             value: 'REPEATED',
                      //           ),
                      //         ],
                      //         value: _frequency,
                      //         onChanged: (value) {
                      //           setState(() {
                      //             _frequency = value;
                      //           });
                      //         })
                      //   ],
                      // ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ))
            ],
          ),
        ));
  }
}
