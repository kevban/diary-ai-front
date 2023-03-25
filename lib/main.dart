import 'dart:convert';

import 'package:diary_ai/app_data.dart';
import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/interview.dart';
import 'package:diary_ai/classes/scenario.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/helpers.dart';
import 'package:diary_ai/pages/discover_page.dart';
import 'package:diary_ai/pages/not_found_page.dart';
import 'package:diary_ai/pages/onboard_page.dart';
import 'package:diary_ai/providers/discovery_provider.dart';
import 'package:diary_ai/widgets/char_widgets/char_details_modal.dart';
import 'package:diary_ai/pages/diary_page.dart';
import 'package:diary_ai/pages/interview_page.dart';
import 'package:diary_ai/pages/new_interview_page.dart';
import 'package:diary_ai/pages/scenario_page.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/providers/scenario_provider.dart';
import 'package:diary_ai/providers/message_provider.dart';
import 'package:diary_ai/theme.dart';
import 'package:diary_ai/widgets/shared/dismiss_keyboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:diary_ai/pages/char_page.dart';
import 'package:diary_ai/pages/chat_page.dart';
import 'package:diary_ai/pages/diary_details_page.dart';
import 'package:diary_ai/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  await AppData.initApp();
  await dotenv.load(fileName: 'dotenv');

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (_) => MessageProvider(interviews: AppData.interviewList)),
      ChangeNotifierProvider.value(
          value: CharacterProvider(characters: AppData.characterList)),
      ChangeNotifierProvider.value(
          value: ScenarioProvider(scenarios: AppData.scenarioList)),
      ChangeNotifierProvider.value(
        value: DiscoverProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

final _router =
    GoRouter(errorBuilder: (context, state) => const NotFoundPage(), routes: [
  GoRoute(path: '/', builder: (context, state) => InterviewPage()),
  GoRoute(
    path: '/chat',
    builder: (context, state) => InterviewPage(),
  ),
  GoRoute(path: '/discover', builder: (context, state) => DiscoverPage()),
  GoRoute(
    path: '/characters',
    builder: (context, state) => CharPage(),
  ),
  GoRoute(
    path: '/scenarios',
    builder: (context, state) => ScenarioPage(),
  ),
  GoRoute(
      path: '/interview/:id',
      builder: (context, state) {
        return ChatPage(
          interviewId: state.params['id']!,
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
    return DismissKeyboard(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'ConverAI',
        routerConfig: _router,
        theme: createTheme(context),
      ),
    );
  }
}
//flutter run -d chrome --web-renderer html
