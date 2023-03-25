import 'dart:convert';

import 'package:diary_ai/app_data.dart';
import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/scenario.dart';
import 'package:diary_ai/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class DiaryAPI {
  static String baseHost = dotenv.env['API_URL']?? '10.0.0.211';

  static Future<dynamic> request(String endpoint, String method,
      {Map<String, dynamic>? queryParameters, Object? body}) async {
    debugPrint('Target: $method https://$baseHost$endpoint. Auth: ${AppData.token}');
    Uri url = Uri(
        scheme: 'https',
        host: baseHost,
        path: endpoint,
        queryParameters: queryParameters);
    switch (method) {
      case 'GET':
        final res = await http
            .get(url, headers: {'authorization': 'Bearer ${AppData.token}'});
        if (res.statusCode != 201 && res.statusCode != 200) {
          throw CustomException(res.statusCode.toString());
        }
        return jsonDecode(res.body);
      case 'POST':
        final res = await http.post(url, body: body, headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer ${AppData.token}' ?? ''
        });
        if (res.statusCode != 201 && res.statusCode != 200) {
          throw CustomException(res.statusCode.toString());
        }
        if (jsonDecode(res.body) is! String) {
          debugPrint(jsonDecode(res.body).toString());
          return jsonDecode(res.body);
        } else {
          debugPrint(jsonDecode(jsonDecode(res.body)).toString());
          return jsonDecode(jsonDecode(res.body));
        } // this is to get rid of the \n at the end of server response
      case 'PATCH':
        final res = await http.patch(url, body: body, headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer ${AppData.token}' ?? ''
        });
        if (res.statusCode != 201 && res.statusCode != 200) {
          throw CustomException(res.statusCode.toString());
        }
        if (jsonDecode(res.body) is! String) {
          debugPrint(jsonDecode(res.body).toString());
          return jsonDecode(res.body);
        } else {
          debugPrint(jsonDecode(jsonDecode(res.body)).toString());
          return jsonDecode(jsonDecode(res.body).toString());
        }
      default:
        return {};
    }
  }

  static Map<String, dynamic> parseOpenAIResponse(dynamic response) {
    return {
      'content': response['choices'].first['message']['content'],
      'tokens': response['usage']['total_tokens']
    };
  }

  static Future<Character> createCharacter(
      {required Map<String, dynamic> body,
      String? imgBase64,
      String? vocab}) async {
    final reqBody = jsonEncode(body);
    final res = await request('/character/generate', 'POST', body: reqBody);
    final parsedRes = parseOpenAIResponse(res);
    AppData.curToken += parsedRes['tokens'] as int;
    String charVocab;
    if (vocab == null || vocab.isEmpty) {
      final vocabRes = await request('/character/vocab', 'POST', body: reqBody);
      final parsedVocabRes = parseOpenAIResponse(vocabRes);
      charVocab = parsedVocabRes['content'];
      AppData.curToken += parsedRes['tokens'] as int;
    } else {
      charVocab = vocab;
    }
    String characteristics = '${body['charName']}${parsedRes['content']}';
    return Character(
        name: body['charName'],
        desc: body['charDesc'],
        vocab: charVocab,
        imgBase64: imgBase64,
        id: const Uuid().v4(),
        characteristics: characteristics.split('\n-'));
  }

  // static Future<String> generateContent(
  //     {required Map<String, dynamic> body}) async {
  //   final reqBody = jsonEncode(body);
  //   print(reqBody);
  //   final facts = await request('/content/extract', 'POST', body: reqBody);
  //   final factsStr =
  //       '${body['topics'][0]}:${facts['choices'].first['message']['content']}';
  //   final contentBody = jsonEncode({
  //     'userName': body['userName'],
  //     'starter': body['starter'],
  //     'contentType': body['contentType'],
  //     'facts': factsStr
  //   });
  //
  //   final content =
  //       await request('/content/generate', 'POST', body: contentBody);
  //   String response =
  //       '${body['starter']}${content['choices'].first['message']['content']}';
  //   return response.trim();
  // }

  static Future<String> getResponse(
      {required Map<String, dynamic> body}) async {
    final reqBody = jsonEncode(body);
    final res = await request('/questions', 'POST', body: reqBody);
    final parsedRes = parseOpenAIResponse(res);
    String response = parsedRes['content'];
    AppData.curToken += parsedRes['tokens'] as int;
    return response.trim();
  }

  static Future<dynamic> initUser({required String? deviceId}) async {
    final reqBody = jsonEncode({'deviceId': deviceId});
    final res = await request('/user', 'POST', body: reqBody);
    return res;
  }

  /// used to fetch top 25 most popular characters from database
  static Future<List<Character>> getPopularCharacters() async {
    final characters = await request('/character', 'GET') as List<dynamic>;
    List<Character> characterList = [];
    for (var character in characters) {
      characterList.add(Character(
          name: character['name'],
          desc: character['desc'],
          vocab: character['vocab'],
          characteristics:
              (character['characteristics'] as List<dynamic>).map((e) {
            if (e is String) {
              return e;
            } else {
              return '';
            }
          }).toList(),
          id: character['id'],
          imgBase64: character['imgBase64'],
          downloads: character['downloads']));
    }
    return characterList;
  }

  /// used to fetch top 25 most popular scenarios from database
  static Future<List<Scenario>> getPopularScenarios() async {
    final scenarios = await request('/scenario', 'GET') as List<dynamic>;
    List<Scenario> scenarioList = [];
    for (var scenario in scenarios) {
      scenarioList.add(Scenario(
          setting: scenario['setting'],
          title: scenario['title'],
          userStart: scenario['userStart'],
          imgBase64: scenario['imgBase64'],
          referenceStrength: scenario['referenceStrength'],
          description: scenario['description'],
          instruction: scenario['instruction'],
          downloads: scenario['downloads'],
          id: scenario['id']));
    }
    return scenarioList;
  }

  static Future<List<Character>> findChar({required String charName}) async {
    final characters = await request('/character', 'GET',
        queryParameters: {'charName': charName}) as List<dynamic>;
    List<Character> characterList = [];
    for (var character in characters) {
      characterList.add(Character(
          name: character['name'],
          desc: character['desc'],
          vocab: character['vocab'],
          characteristics:
              (character['characteristics'] as List<dynamic>).map((e) {
            if (e is String) {
              return e;
            } else {
              return '';
            }
          }).toList(),
          id: character['id'],
          imgBase64: character['imgBase64'],
          downloads: character['downloads']));
    }
    return characterList;
  }

  static Future<void> addChar({required Character character}) async {
    final reqBody = jsonEncode(character);
    debugPrint('${character.name} added');
    await request('/character', 'POST', body: reqBody);
  }

  static Future<List<Scenario>> findScenario(
      {required String scenarioTitle}) async {
    final scenarios = await request('/scenario', 'GET',
        queryParameters: {'scenarioTitle': scenarioTitle}) as List<dynamic>;
    List<Scenario> scenarioList = [];
    for (var scenario in scenarios) {
      scenarioList.add(Scenario(
          setting: scenario['setting'],
          title: scenario['title'],
          userStart: scenario['userStart'],
          imgBase64: scenario['imgBase64'],
          referenceStrength: scenario['referenceStrength'],
          description: scenario['description'],
          instruction: scenario['instruction'],
          downloads: scenario['downloads'],
          id: scenario['id']));
    }
    return scenarioList;
  }

  static Future<void> addScenario({required Scenario scenario}) async {
    final reqBody = jsonEncode(scenario);
    debugPrint('${scenario.title} added');
    await request('/scenario', 'POST', body: reqBody);
  }

  static Future<void> addCharDownload({required String id}) async {
    final reqBody = jsonEncode({'id': id});
    await request('/character/downloads', 'PATCH', body: reqBody);
    return null;
  }

  static Future<void> addScenarioDownload({required String id}) async {
    final reqBody = jsonEncode({'id': id});
    await request('/scenario/downloads', 'PATCH', body: reqBody);
    return null;
  }
}
