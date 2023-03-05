import 'dart:convert';
import 'dart:ui';

import 'package:diary_ai/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'character.g.dart';

@JsonSerializable()
class Character {
  String id = const Uuid().v4();
  String name;
  String desc;
  String vocab;


  String? imgBase64;

  List<String> characteristics;

  Character(
      {required this.name,
      required this.desc,
      required this.vocab,
      required this.characteristics,
      this.imgBase64});

  ImageProvider? getImage() {
    if (imgBase64 != null) {
      final imgBytes = base64Decode(imgBase64!);
      return MemoryImage(imgBytes);
    }
    return null;
  }

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterToJson(this);
// flutter pub run build_runner build
}
