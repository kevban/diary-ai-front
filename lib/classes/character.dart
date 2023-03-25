import 'dart:convert';
import 'dart:ui';

import 'package:diary_ai/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'character.g.dart';

@JsonSerializable()
class Character {
  String id;
  String name;
  String desc;
  String vocab;
  int? downloads; // this keep track of the downloads for server characters

  String? imgBase64;

  List<String> characteristics;

  Character(
      {required this.name,
      required this.desc,
      required this.vocab,
      required this.characteristics,
      this.imgBase64,
      this.downloads,
      required this.id}) {
  }

  ImageProvider? getImage() {
    if (imgBase64 != null) {
      final imgBytes = base64Decode(imgBase64!);
      return MemoryImage(imgBytes);
    }
    return null;
  }

  /// if this evaluates to true, the character is uploaded to the server
  bool isComplete() {
    return imgBase64 != null && characteristics.length >= 15;
  }

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterToJson(this);
// flutter pub run build_runner build
}
