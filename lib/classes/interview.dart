import 'dart:convert';
import 'dart:math';

import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/content.dart';
import 'package:diary_ai/classes/message.dart';
import 'package:diary_ai/helpers.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'interview.g.dart';

@JsonSerializable()
class Interview {
  String id = const Uuid().v4();
  String?
      characterName; // this is the character, which is represented by the charName
  List<String> topics = []; // this will be the list of things AI will ask.
  String contentType = 'diary';
  String contentStarter = 'Dear diary,\n';
  String title =
      'Diary'; // the title of the interview. Used in display and file directory
  String repeat = 'daily'; // how often the interview is repeated
  DateTime time =
      DateTime.now(); // the next time this interview becomes available
  List<Message> messages = [];
  List<Message> currentMessages = [];
  String status = "STANDBY";
  String userName;
  String userDesc;

  Interview(
      {this.characterName,
      required this.userName,
      required this.userDesc,
      required this.topics,
      required this.contentStarter,
      required this.contentType,
      required this.title});

  /// returns a string representation of the current messages
  String compileMessages({int? maxMsg}) {
    maxMsg ??= currentMessages.length;
    int start = currentMessages.length - maxMsg;
    List<String> messageList = [];
    for (int i = start; i < currentMessages.length; i++) {
      if (currentMessages[i].sender == 'Me') {
        messageList.add('$userName: ${currentMessages[i].text}');
      } else {
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

  void pushMessages({required Message newMsg}) async {
    messages.add(newMsg);
    currentMessages.add(newMsg);
    await LocalStorage.saveLocalFile('/interviews', jsonEncode(this), identifier: id);
  }


  void reset() {
    currentMessages.clear();
    status = 'STANDBY';
  }

  factory Interview.fromJson(Map<String, dynamic> json) =>
      _$InterviewFromJson(json);

  Map<String, dynamic> toJson() => _$InterviewToJson(this);
// flutter pub run build_runner build
}
