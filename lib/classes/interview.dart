import 'dart:convert';
import 'dart:math';

import 'package:diary_ai/app_data.dart';
import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/scenario.dart';
import 'package:diary_ai/classes/message.dart';
import 'package:diary_ai/config.dart';
import 'package:diary_ai/helpers.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'interview.g.dart';

@JsonSerializable()
class Interview {
  String id = const Uuid().v4();
  String
      characterId; // this is the character, which is represented by the characterId
  String scenarioId; // this is the scenario, which is represented by scenarioId
  String title; // the title of the interview. Used in display
  DateTime lastMessage = DateTime.now(); // the timestamp of last message sent
  List<Message> messages = [];
  List<Message> currentMessages = [];
  String status = "STANDBY";

  Interview(
      {required this.characterId,
      required this.scenarioId,
      required this.title});

  /// returns a string representation of the current messages
  String compileMessages({int? maxMsg}) {
    maxMsg ??= currentMessages.length;
    int start = max(currentMessages.length - maxMsg, 0);
    List<String> messageList = [];
    for (int i = start; i < currentMessages.length; i++) {
      if (currentMessages[i].sender == 'Me') {
        messageList.add('${AppData.userName}: ${currentMessages[i].text}');
      } else if (currentMessages[i].sender != 'System') {
        messageList
            .add('${currentMessages[i].sender}: ${currentMessages[i].text}');
      }
    }
    return messageList.join('\n');
  }

  List<Message> getMessages({int? maxMsg, bool history = true}) {
    List<Message> returnedMsg = [];
    if (history) {
      maxMsg ??= messages.length;
      int start = messages.length - maxMsg;
      for (int i = start; i < messages.length; i++) {
        returnedMsg.add(messages[i]);
      }
    } else {
      maxMsg ??= currentMessages.length;
      int start = currentMessages.length - maxMsg;
      for (int i = start; i < currentMessages.length; i++) {
        returnedMsg.add(currentMessages[i]);
      }
    }
    return returnedMsg;
  }

  Future<void> pushMessages(
      {required Message newMsg, bool error = false}) async {
    messages.add(newMsg);
    currentMessages.add(newMsg);
    lastMessage = DateTime.now();
    await LocalStorage.saveLocalFile('/interviews', jsonEncode(this),
        fileName: id, identifier: id);
  }

  /// returns the string representation of the last message
  String getDate() {
    DateTime today = DateTime.now();
    DateFormat dateFormatter = DateFormat('Md');
    DateFormat timeFormatter = DateFormat('Hm');
    String todayStr = dateFormatter.format(today);
    String lastMsgStr = dateFormatter.format(lastMessage);

    if (todayStr != lastMsgStr) {
      return lastMsgStr;
    } else {
      return timeFormatter.format(lastMessage);
    }
  }

  void reset() {
    messages.clear();
    currentMessages.clear();
    status = 'STANDBY';
  }

  factory Interview.fromJson(Map<String, dynamic> json) =>
      _$InterviewFromJson(json);

  Map<String, dynamic> toJson() => _$InterviewToJson(this);
// flutter pub run build_runner build
}
