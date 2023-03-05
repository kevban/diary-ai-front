import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'content.g.dart';

@JsonSerializable()
class Content {
  String id = const Uuid().v4();
  final String content;
  final String title;
  final DateTime timestamp;
  final Map<String, String> metaData = {};

  Content({required this.content, required this.title, required this.timestamp});

  factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);
  Map<String, dynamic> toJson() => _$ContentToJson(this);
// flutter pub run build_runner build
}