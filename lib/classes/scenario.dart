import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'scenario.g.dart';

@JsonSerializable()
class Scenario {
  String id;
  String title;
  String? description;
  String? instruction;
  String setting;
  String? imgBase64;
  double referenceStrength;
  int? downloads; // to track downloads for server Scenarios
  bool userStart;

  Scenario(
      {required this.setting,
      this.userStart = false,
      required this.title,
      this.description,
      this.referenceStrength = 0.5,
      this.instruction,
      this.imgBase64,
      required this.id,
      this.downloads});

  ImageProvider? getImage() {
    if (imgBase64 != null) {
      final imgBytes = base64Decode(imgBase64!);
      return MemoryImage(imgBytes);
    }
    return null;
  }

  bool isComplete() {
    return description != null &&
        description!.isNotEmpty &&
        setting.length > 20 &&
        imgBase64 != null;
  }

  factory Scenario.fromJson(Map<String, dynamic> json) =>
      _$ScenarioFromJson(json);

  Map<String, dynamic> toJson() => _$ScenarioToJson(this);
// flutter pub run build_runner build
}
