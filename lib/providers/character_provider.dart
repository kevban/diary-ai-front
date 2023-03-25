import 'dart:convert';
import 'dart:math';

import 'package:diary_ai/app_data.dart';
import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/helpers.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/classes/message.dart';

/// The class responsible for user characters
class CharacterProvider with ChangeNotifier {
  final List<Character> characters;

  CharacterProvider({required this.characters});

  Future<bool> createCharacter({required String name,
    required String desc,
    String? imgBase64,
    String? vocab}) async {
    // if (AppData.curToken > 10000) {
    //   return false;
    // }
    Map<String, dynamic> body = {
      'charName': name,
      'charDesc': desc,
    };
    try {
      Character newChar = await DiaryAPI.createCharacter(
          body: body, imgBase64: imgBase64, vocab: vocab);
      characters.add(newChar);
      LocalStorage.saveLocalFile('/characters', jsonEncode(newChar),
          fileName: newChar.id);
      if (newChar.isComplete()) {
        DiaryAPI.addChar(character: newChar); // not awaited to reduce wait time
      }
      notifyListeners();
      return true;
    } catch (e) {
      if (e is CustomException) {
        if (e.cause == '401') {
          AppData.initializeUser(regenToken: true);
        }
      }
    }
    return true;
  }

  Future<void> downloadCharacter({required Character character}) async {
    if (getCharacterById(character.id) == null) {
      characters.add(character);
      DiaryAPI.addCharDownload(id: character.id);
      await LocalStorage.saveLocalFile('/characters', jsonEncode(character),
          fileName: character.id);
      notifyListeners();
    }
  }

  Future<void> removeCharacterById(String id) async {
    await LocalStorage.removeLocalFile('/characters',
        fileName: id, identifier: id);
    characters.removeWhere((character) => character.id == id);
    notifyListeners();
  }

  Character? getCharacterById(String id) {
    for (Character char in characters) {
      if (char.id == id) {
        return char;
      }
    }
    return null;
  }

  Future<void> updateCharacter(
      {required String name, required String desc, required String vocab, required List<
          String> characteristics, required String id, required String? imgBase64}) async {
    for (int i = 0; i < characters.length; i++) {
      if (characters[i].id == id) {
        characters[i].name = name;
        characters[i].desc = desc;
        characters[i].vocab = vocab;
        characters[i].characteristics = characteristics;
        characters[i].imgBase64 = imgBase64;
        await LocalStorage.saveLocalFile('/characters', jsonEncode(characters[i]),
            fileName: characters[i].id, identifier: characters[i].id);
        notifyListeners();
        break;
      }
    }
  }
}
