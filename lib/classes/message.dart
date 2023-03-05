import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String text;
  final String sender;
  final DateTime timestamp;

  Message({required this.text, required this.sender, required this.timestamp});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
  // flutter pub run build_runner build
}