import 'dart:convert';
import 'dart:math';

import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/helpers.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/classes/message.dart';

/// The class responsible for user characters
class CharacterProvider with ChangeNotifier {
  final List<Character> characters;

  CharacterProvider({required this.characters});

  Future<Character> createCharacter(
      String name, String desc, ImageProvider? image, String? imgBase64) async {
    Map<String, dynamic> body = {
      'charName': name,
      'charDesc': desc,
    };
    Character newChar =
        await DiaryAPI.createCharacter(body: body, imgBase64: imgBase64);
    characters.add(newChar);
    LocalStorage.saveLocalFile('/characters', jsonEncode(newChar));
    notifyListeners();
    return newChar;
  }

  Character? findCharacterByName(String? name) {
    if (name != null) {
      for (Character char in characters) {
        if (char.name == name) {
          return char;
        }
      }
    }
    return null;
  }

  void updateCharacter(Character character) {
    for (int i = 0; i < characters.length; i++) {
      if (characters[i].name == character.name) {
        characters[i] = character;
        break;
      }
    }
  }
}
