import 'dart:convert';
import 'dart:math';

import 'package:diary_ai/app_data.dart';
import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/scenario.dart';
import 'package:diary_ai/config.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/helpers.dart';
import 'package:diary_ai/providers/scenario_provider.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/classes/message.dart';
import 'package:diary_ai/classes/interview.dart';
import 'package:provider/provider.dart';

/// The class responsible for managing chat functions
class MessageProvider with ChangeNotifier {
  List<Interview> interviews;

  MessageProvider({required this.interviews});

  Interview? getInterviewById(String id) {
    for (Interview interview in interviews) {
      if (interview.id == id) {
        return interview;
      }
    }
    return null;
  }

  // void setCharacter(Character character, String interviewTitle) {
  //   _character = character;
  // }

  /// changing first person to user
  List<String> parseTopics(List<String> topics, String userName) {
    List<String> parsedTopics = [];
    for (String topic in topics) {
      String result = topic.split(' ').map((word) {
        final lowercase = word.toLowerCase();
        if (lowercase == 'me' || lowercase == 'i') {
          return userName;
        } else if (lowercase == 'my') {
          return "$userName's";
        } else {
          return word;
        }
      }).join(' ');
      parsedTopics.add(result);
    }

    return parsedTopics;
  }

  /// this function replaces all char and user with charName and userName
  String parseSetting(String setting, String userName, String charName) {
    return setting
        .replaceAll(RegExp(r"\buser\b"), userName)
        .replaceAll(RegExp(r"\bchar\b"), charName);
  }

  String? getRandomReference(Character character, double referenceStrength) {
    Random random = Random();
    double randDouble = random.nextDouble();
    if (randDouble < referenceStrength) {
      if (character.characteristics.isNotEmpty) {
        String reference = character
            .characteristics[random.nextInt(character.characteristics.length)];
        return reference;
      } else {
        return character.name;
      }
    }
    return null;
  }

  // void updateSettings(String userName, List<String> topics) {
  //   _topics = topics.map((topic) => parseTopic(topic)).toList();
  //   _userName = userName;
  //   notifyListeners();
  // }

  Interview addInterview(
      {required String characterId,
      required String scenarioId,
      required String title}) {
    Interview interview = Interview(
        characterId: characterId, scenarioId: scenarioId, title: title);
    interviews.add(interview);
    LocalStorage.saveLocalFile('/interviews', jsonEncode(interview),
        fileName: interview.id);
    notifyListeners();
    return interview;
  }

  void removeInterviewById({required String id}) {
    interviews.removeWhere((element) => element.id == id);
    LocalStorage.removeLocalFile('/interviews', identifier: id, fileName: id);
    notifyListeners();
  }

  Future<void> restartInterview(
      {required Interview interview,
      required Character character,
      required Scenario scenario}) async {
    interview.reset();
    notifyListeners();
  }

  /// this is called whenever user send a message. If newMsg is null, the message is initiated by the bot instead
  Future<bool> userMsg(
      {Message? newMsg,
      required Interview interview,
      required Character character,
      required Scenario scenario}) async {
    if (interview == null || interview.status == 'ENDED') {
      return false;
    }
    // if (AppData.curToken > 10000 && !AppData.premium) {
    //   return false;
    // }
    if (newMsg != null) {
      pushMessage(newMsg!, interview);
    }
    interview.status = 'TYPING';
    notifyListeners();
    String? reference =
        getRandomReference(character, scenario.referenceStrength);
    try {
      Map<String, dynamic> body = {
        'charName': character.name,
        'charDesc': character.desc,
        'vocab': character.vocab,
        'userName': AppData.userName,
        'userDesc': 'a stranger',
        'settings':
            parseSetting(scenario.setting, AppData.userName, character.name),
        'reference': reference,
        'prevConversation': interview.compileMessages(maxMsg: 6),
        'vocabOverride': scenario.instruction,
        'userStart': scenario.userStart,
      };
      final response = await DiaryAPI.getResponse(body: body);
      interview.status = 'ACTIVE';
      pushMessage(
          Message(
              text: response,
              sender: character.name,
              timestamp: DateTime.now()),
          interview);
    } catch (e) {
      interview.status = 'ACTIVE';
      pushMessage(
          Message(
              text: 'Network Error',
              sender: 'System',
              timestamp: DateTime.now()),
          interview);
      if (e is CustomException) {
        if (e.cause == '401') {
          AppData.initializeUser(regenToken: true);
        }
      }
    }
    return true;
  }

  void pushMessage(Message newMsg, Interview interview) async {
    await interview.pushMessages(newMsg: newMsg);
    notifyListeners();
    // if (interview.currentMessages.last.text.contains('ENDOFCONV')) {
    //   endConversation(interview);
    // }
  }

  // void saveContent({required Interview interview, String? title}) {
  //   DateTime today = DateTime.now();
  //   Content content = Content(
  //       content: interview.messages.last.text,
  //       title: title ?? '${interview.title}_${today.month}-${today.day}',
  //       timestamp: DateTime.now());
  //   LocalStorage.saveLocalFile('/content', jsonEncode(content));
  //   interview.reset();
  //   notifyListeners();
  // }

  // void endConversation(Interview interview) async {
  //   interview.status = 'ENDED';
  //   notifyListeners();
  //   Map<String, dynamic> body = {
  //     'contentType': interview.contentType,
  //     'topics': parseTopics(interview.topics, interview.userName),
  //     'conversation': interview.compileMessages(),
  //     'userName': interview.userName,
  //     'starter': interview.contentStarter
  //   };
  //   String content = await DiaryAPI.generateContent(body: body);
  //   interview.currentMessages.add(
  //       Message(text: content, sender: 'System', timestamp: DateTime.now()));
  //   interview.status = 'SAVE';
  //   notifyListeners();
  // }

}
