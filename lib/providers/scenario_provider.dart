import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/scenario.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/helpers.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/classes/message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'message_provider.dart';

/// The class responsible for diary
class ScenarioProvider with ChangeNotifier {
  List<Scenario> scenarios;

  ScenarioProvider({required this.scenarios});

  /// Adding content to localStorage
  /// content -> actual content
  /// chat -> the chat history between ai and user
  /// relativePath -> the path to save the content file, e.g. /diaries
  Future<void> addScenario(
      {required String title,
      required String setting,
      required String? description,
      double? referenceStrength,
      required bool userStart,
      String? instruction,
      String? imgBase64}) async {
    Scenario scenario = Scenario(
      id: const Uuid().v4(),
        setting: setting,
        title: title,
        description: description,
        referenceStrength: referenceStrength ?? 0.5,
        instruction: instruction,
        userStart: userStart,
        imgBase64: imgBase64);
    await LocalStorage.saveLocalFile('/scenarios', jsonEncode(scenario),
        fileName: scenario.id);
    scenarios.add(scenario);
    if (scenario.isComplete()) {
      DiaryAPI.addScenario(scenario: scenario);
    }
    notifyListeners();
  }

  Future<void> downloadScenario({required Scenario scenario}) async {
    if (getScenarioById(id: scenario.id) == null) {
      scenarios.add(scenario);
      DiaryAPI.addScenarioDownload(id: scenario.id);
      await LocalStorage.saveLocalFile('/scenarios', jsonEncode(scenario),
          fileName: scenario.id);
      notifyListeners();
    }
  }


  Scenario? getScenarioById({required String id}) {
    for (Scenario scenario in scenarios) {
      if (scenario.id == id) {
        return scenario;
      }
    }
    return null;
  }

  Future<void> updateScenario(
      {required String title,
      required String desc,
      required double referenceStrength,
      required String setting,
      required bool userStart,
      required String id,
      required String? instruction,
      required String? imgBase64}) async {
    for (int i = 0; i < scenarios.length; i++) {
      if (scenarios[i].id == id) {
        scenarios[i].title = title;
        scenarios[i].description = desc;
        scenarios[i].referenceStrength = referenceStrength;
        scenarios[i].imgBase64 = imgBase64;
        scenarios[i].instruction = instruction;
        scenarios[i].userStart = userStart;
        scenarios[i].setting = setting;
        await LocalStorage.saveLocalFile('/scenarios', jsonEncode(scenarios[i]),
            fileName: scenarios[i].id, identifier: scenarios[i].id);
        notifyListeners();
        break;
      }
    }
  }

  Future<void> removeScenarioById(String id) async {
    await LocalStorage.removeLocalFile('/scenarios',
        fileName: id, identifier: id);
    scenarios.removeWhere((scenario) => scenario.id == id);
    notifyListeners();
  }
}
