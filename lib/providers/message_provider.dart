import 'dart:convert';
import 'dart:math';

import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/content.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/helpers.dart';
import 'package:diary_ai/providers/content_provider.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/classes/message.dart';
import 'package:diary_ai/classes/interview.dart';
import 'package:provider/provider.dart';

/// The class responsible for managing chat functions
class MessageProvider with ChangeNotifier {
  List<Interview> interviews;

  MessageProvider({required this.interviews});

  Interview? getInterviewByTitle(String title) {
    for (Interview interview in interviews) {
      if (interview.title == title) {
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

  String getRandomReference(Character character) {
    if (character.characteristics.isNotEmpty) {
      Random random = Random();
      String reference = character
          .characteristics[random.nextInt(character.characteristics.length)];
      return reference;
    } else {
      return character.name;
    }
  }

  // void updateSettings(String userName, List<String> topics) {
  //   _topics = topics.map((topic) => parseTopic(topic)).toList();
  //   _userName = userName;
  //   notifyListeners();
  // }

  void addInterview(Interview interview) {
    interviews.add(interview);
    LocalStorage.saveLocalFile('/interviews', jsonEncode(interview));
    print(interview.id);
    notifyListeners();
  }

  /// this is called whenever user send a message. If newMsg is null, the message is initiated by the bot instead
  void userMsg(
      {Message? newMsg,
      required String interviewTitle,
      required Character character}) async {
    Interview? interview = getInterviewByTitle(interviewTitle);
    if (interview == null || interview.status == 'ENDED') {
      return;
    }
    // adding user message
    if (interview.status == 'ACTIVE') {
      pushMessage(newMsg!, interview);
      interview.status = 'TYPING';
      notifyListeners();
    }
    String reference = getRandomReference(character);
    try {
      Map<String, dynamic> body = {
        'charName': character.name,
        'charDesc': character.desc,
        'vocab': character.vocab,
        'userName': interview.userName,
        'userDesc': interview.userDesc,
        'reference': reference,
        'topics': parseTopics(interview.topics, interview.userName),
        'prevConversation': interview.compileMessages()
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
      print(e);
      pushMessage(
          Message(text: 'Network Error', sender: '', timestamp: DateTime.now()),
          interview);
    }
  }

  void pushMessage(Message newMsg, Interview interview) async {
    interview.currentMessages.add(newMsg);
    notifyListeners();
    if (interview.currentMessages.last.text.contains('ENDOFCONV')) {
      endConversation(interview);
    }
  }

  void saveContent({required Interview interview, String? title}) {
    DateTime today = DateTime.now();
    Content content = Content(
        content: interview.messages.last.text,
        title: title ?? '${interview.title}_${today.month}-${today.day}',
        timestamp: DateTime.now());
    LocalStorage.saveLocalFile('/content', jsonEncode(content));
    interview.reset();
    notifyListeners();
  }

  void endConversation(Interview interview) async {
    interview.status = 'ENDED';
    notifyListeners();
    Map<String, dynamic> body = {
      'contentType': interview.contentType,
      'topics': parseTopics(interview.topics, interview.userName),
      'conversation': interview.compileMessages(),
      'userName': interview.userName,
      'starter': interview.contentStarter
    };
    String content = await DiaryAPI.generateContent(body: body);
    interview.currentMessages.add(
        Message(text: content, sender: 'System', timestamp: DateTime.now()));
    interview.status = 'SAVE';
    notifyListeners();
  }

  void reset(Interview interview) {
    interview.reset();
    notifyListeners();
  }
}
