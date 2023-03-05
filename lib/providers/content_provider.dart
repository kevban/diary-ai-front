import 'dart:io';
import 'dart:math';

import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/content.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/helpers.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/classes/message.dart';
import 'package:path_provider/path_provider.dart';

import 'message_provider.dart';

/// The class responsible for diary
class ContentProvider with ChangeNotifier {

  ContentProvider();

  /// Adding content to localStorage
  /// content -> actual content
  /// chat -> the chat history between ai and user
  /// relativePath -> the path to save the content file, e.g. /diaries
  Future<void> addContent(
      {String? title,
      required String content,
      required String relativePath,
      required String chat}) async {
    // all content will contain meta data at the beginning in key:value pairs in each line. Finish
    // meta data with \n---
    DateTime today = DateTime.now();
    String timestamp =
        '${today.month}-${today.day} ${today.hour}:${today.minute}:${today.second}';
    title ??= '${relativePath.replaceAll('/', '')}-$timestamp';
    final metaData = {'title': title, 'timestamp': timestamp};
    String metaDataStr = serializeMetaData(metaData);
    await LocalStorage.saveLocalFile(
        '$relativePath/$title.txt', '$metaDataStr$content');
    await LocalStorage.saveLocalFile('$relativePath/$title-chat.txt', chat);
  }
}
