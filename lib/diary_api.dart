import 'dart:convert';

import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class DiaryAPI {
  static String baseHost = '10.0.0.211';

  static Future<Map<String, dynamic>> request(String endpoint, String method,
      {Map<String, dynamic>? queryParameters, Object? body}) async {
    print('Target: $method http://$baseHost$endpoint');
    Uri url = Uri(
        scheme: 'http',
        host: baseHost,
        path: endpoint,
        port: 8080,
        queryParameters: queryParameters);
    switch (method) {
      case 'GET':
        final res = await http.get(url);
        return jsonDecode(res.body);
      case 'POST':
        final res = await http.post(url,
            body: body, headers: {'Content-Type': 'application/json'});

        if (jsonDecode(res.body) is! String) {
          print(jsonDecode(res.body));
          return jsonDecode(res.body);
        } else {
          print(jsonDecode(jsonDecode(res.body)));
          return jsonDecode(jsonDecode(res.body));
        } // this is to get rid of the \n at the end of server response
      default:
        return {};
    }
  }

  static Future<Character> createCharacter(
      {required Map<String, dynamic> body, String? imgBase64}) async {
    final reqBody = jsonEncode(body);
    final res = await request('/character', 'POST', body: reqBody);
    return Character(
        name: body['charName'],
        desc: body['charDesc'],
        vocab: jsonDecode(res['vocab'])['choices'].first['message']['content'],
        imgBase64: imgBase64,
        characteristics: jsonDecode(res['characteristics'])['choices']
            .first['message']['content']
            .split('\n-'));
  }

  static Future<String> generateContent(
      {required Map<String, dynamic> body}) async {
    final reqBody = jsonEncode(body);
    print(reqBody);
    final facts = await request('/content/extract', 'POST', body: reqBody);
    final factsStr =
        '${body['topics'][0]}:${facts['choices'].first['message']['content']}';
    final contentBody = jsonEncode({
      'userName': body['userName'],
      'starter': body['starter'],
      'contentType': body['contentType'],
      'facts': factsStr
    });

    final content =
        await request('/content/generate', 'POST', body: contentBody);
    String response =
        '${body['starter']}${content['choices'].first['message']['content']}';
    return response.trim();
  }

  static Future<String> getResponse(
      {required Map<String, dynamic> body}) async {
    final reqBody = jsonEncode(body);
    final question = await request('/questions', 'POST', body: reqBody);
    String response = question['choices'].first['message']['content'];
    return response.trim();
  }

  static Future<List<Character>> getCharacters() async {
    final characters = await request('/character', 'GET');
    List<Character> characterList = [];
    for (var e in characters['characters']) {
      characterList.add(Character(
          name: e['name'],
          desc: e['desc'],
          vocab: e['vocab'],
          imgBase64: e['imgBase64'],
          characteristics: (e['characteristics'] as List<dynamic>)
              .map((e) => e as String)
              .toList()));
    }
    return characterList;
  }
}
