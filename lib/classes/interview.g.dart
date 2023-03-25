// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Interview _$InterviewFromJson(Map<String, dynamic> json) => Interview(
      characterId: json['characterId'] as String,
      scenarioId: json['scenarioId'] as String,
      title: json['title'] as String,
    )
      ..id = json['id'] as String
      ..lastMessage = DateTime.parse(json['lastMessage'] as String)
      ..messages = (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList()
      ..currentMessages = (json['currentMessages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList()
      ..status = json['status'] as String;

Map<String, dynamic> _$InterviewToJson(Interview instance) => <String, dynamic>{
      'id': instance.id,
      'characterId': instance.characterId,
      'scenarioId': instance.scenarioId,
      'title': instance.title,
      'lastMessage': instance.lastMessage.toIso8601String(),
      'messages': instance.messages,
      'currentMessages': instance.currentMessages,
      'status': instance.status,
    };
