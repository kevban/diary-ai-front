import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'classes/character.dart';
import 'classes/interview.dart';
import 'classes/scenario.dart';
import 'helpers.dart';

class AppData {
  static List<Character> characterList = [];
  static List<Interview> interviewList = [];
  static List<Scenario> scenarioList = [];
  static String userName = 'Kevin';
  static String? userImgBase64;
  static int curToken = 0;
  static bool premium = false;
  static String? token;
  static String appName = 'Chat AI';
  static Map<String, bool> tutorials = {
    'newChat': false,
    'discover': false,
  };

  static void showTutorial(String tutorialName) {
    tutorials[tutorialName] = true;
    LocalStorage.setLocalStorage(tutorialName, true, 'bool');
  }

  static ImageProvider? getImage() {
    if (userImgBase64 != null) {
      final imgBytes = base64Decode(userImgBase64!);
      return MemoryImage(imgBytes);
    }
    return null;
  }

  static Future<void> initializeUser({String? name, String? imgBase64, bool? regenToken}) async {
    if (token == null || regenToken == true) {
      String? deviceId = await _getId();
      final res = await DiaryAPI.initUser(deviceId: deviceId);
      curToken = res['curToken'];
      token = res['token'];
      LocalStorage.setLocalStorage('userToken', res['token'], 'string');
      LocalStorage.setLocalStorage('curToken', res['curToken'], 'int');
    }
    if (name != null) {
      userName = name;
      LocalStorage.setLocalStorage('userName', name, 'string');
    }
    if (imgBase64 != null) {
      userImgBase64 = imgBase64;
      LocalStorage.setLocalStorage('userAvatar', imgBase64 ?? '', 'string');
    }
  }

  static Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      var webInfo = await deviceInfo.webBrowserInfo;
      return '${webInfo.vendor} + ${webInfo.userAgent} + ${webInfo.hardwareConcurrency.toString()} + ${webInfo.deviceMemory.toString()} + ${webInfo.languages.toString()}';
    } else if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
    return null;
  }

  static Future<void> initApp() async {
    late List<String> characters;
    late List<String> interviews;
    late List<String> scenarios;
    await Future.wait([
      LocalStorage.getLocalStorage('userToken'),
      LocalStorage.getLocalFiles('/characters'),
      LocalStorage.getLocalFiles('/interviews'),
      LocalStorage.getLocalFiles('/scenarios'),
      LocalStorage.getLocalStorage('userName'),
      LocalStorage.getLocalStorage('userAvatar'),
      LocalStorage.getLocalStorage('newChat'),
      LocalStorage.getLocalStorage('discover'),
    ]).then((values) {
      token = values[0];
      characters = values[1];
      interviews = values[2];
      scenarios = values[3];
      userName = values[4] ?? 'Kevin';
      userImgBase64 = values[5];
      tutorials['newChat'] = values[6] ?? false;
      tutorials['discover'] = values[7] ?? false;
    });

    if (token != null) {
      if (!kIsWeb) {
        for (String filename in characters) {
          String? characterContent =
              await LocalStorage.getLocalFile('/characters/$filename');
          try {
            if (characterContent != null && characterContent.isNotEmpty) {
              characterList
                  .add(Character.fromJson(jsonDecode(characterContent)));
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        }
        for (String filename in interviews) {
          String? interviewContent =
              await LocalStorage.getLocalFile('/interviews/$filename');
          try {
            if (interviewContent != null && interviewContent.isNotEmpty) {
              interviewList
                  .add(Interview.fromJson(jsonDecode(interviewContent)));
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        }
        for (String filename in scenarios) {
          String? scenarioContent =
              await LocalStorage.getLocalFile('/scenarios/$filename');
          try {
            if (scenarioContent != null && scenarioContent.isNotEmpty) {
              scenarioList.add(Scenario.fromJson(jsonDecode(scenarioContent)));
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      } else {
        /// for web, the list retrieved from getLocalFiles is the list of items, instead of file names
        for (String character in characters) {
          characterList.add(Character.fromJson(jsonDecode(character)));
        }
        for (String interview in interviews) {
          interviewList.add(Interview.fromJson(jsonDecode(interview)));
        }
        for (String scenario in scenarios) {
          scenarioList.add(Scenario.fromJson(jsonDecode(scenario)));
        }
      }
    }
  }
}
