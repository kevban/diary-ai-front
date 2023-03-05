import 'dart:convert';

import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/interview.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/helpers.dart';
import 'package:diary_ai/pages/char_details_page.dart';
import 'package:diary_ai/pages/diary_page.dart';
import 'package:diary_ai/pages/interview_page.dart';
import 'package:diary_ai/pages/new_interview_page.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/providers/content_provider.dart';
import 'package:diary_ai/providers/message_provider.dart';
import 'package:diary_ai/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:diary_ai/pages/char_page.dart';
import 'package:diary_ai/pages/chat_page.dart';
import 'package:diary_ai/pages/diary_details_page.dart';
import 'package:diary_ai/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final characters = await LocalStorage.getLocalFiles('/characters');
  final interviews = await LocalStorage.getLocalFiles('/interviews');
  List<Character> characterList = [];
  List<Interview> interviewList = [];
  if (!kIsWeb) {
    for (String filename in characters) {
      String? characterContent =
          await LocalStorage.getLocalFile('/characters/$filename');
      if (characterContent != null) {
        characterList.add(Character.fromJson(jsonDecode(characterContent)));
      }
    }
    for (String filename in interviews) {
      String? interviewContent =
          await LocalStorage.getLocalFile('/interviews/$filename');
      if (interviewContent != null) {
        interviewList.add(Interview.fromJson(jsonDecode(interviewContent)));
      }
    }
  } else {
    /// for web, the list retrieved from getLocalFiles is the lsit of items, instead of file names
    for (String character in characters) {
      characterList.add(Character.fromJson(jsonDecode(character)));
    }
    for (String interview in interviews) {
      interviewList.add(Interview.fromJson(jsonDecode(interview)));
    }
  }

  final content = await LocalStorage.getLocalFiles('/content');

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (_) => MessageProvider(interviews: interviewList)),
      ChangeNotifierProvider.value(
          value: CharacterProvider(characters: characterList)),
      ChangeNotifierProvider.value(value: ContentProvider()),
    ],
    child: const MyApp(),
  ));
}

final _router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => InterviewPage(),
  ),
  GoRoute(
    path: '/characters',
    builder: (context, state) => CharPage(),
  ),
  GoRoute(
    path: '/characters/:name',
    builder: (context, state) => CharacterDetailsPage(
      character: context
          .read<CharacterProvider>()
          .findCharacterByName(state.params['name']),
    ),
  ),
  GoRoute(
    path: '/diary',
    builder: (context, state) => ContentPage(),
  ),
  GoRoute(
      path: '/interview/:title',
      builder: (context, state) {
        return ChatPage(
          interviewTitle: state.params['title']!,
        );
      }),
  GoRoute(
      path: '/interviews/new', builder: (context, state) => NewInterviewPage()),
  GoRoute(
    path: '/diary/:id',
    builder: (context, state) {
      return DiaryDetailsPage(
        title: 'hi',
        date: 'bye',
      );
    },
  ),
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: appTheme,
    );
  }
}
//flutter run -d chrome --web-renderer html
