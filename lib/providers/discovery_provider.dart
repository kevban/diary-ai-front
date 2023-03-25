import 'dart:convert';
import 'dart:math';

import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/helpers.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/classes/message.dart';

import '../classes/scenario.dart';

/// The class responsible for displaying server data
class DiscoverProvider with ChangeNotifier {
  List<Character>? popularCharacters;
  List<Character> loadedChar = [];
  List<Scenario>? popularScenarios;
  List<Scenario> loadedScenario = [];
  bool loading = false;
  Map<String, int> downloads= {}; // this maps uid to downloads

  /// this function fetches popularCharacter
  void initDiscover() async {

    if (popularCharacters == null && !loading) {
      loading = true;
      popularCharacters = await DiaryAPI.getPopularCharacters();
      popularScenarios = await DiaryAPI.getPopularScenarios();
      notifyListeners();
    }

  }
  DiscoverProvider();

}
