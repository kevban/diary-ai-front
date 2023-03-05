// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Interview _$InterviewFromJson(Map<String, dynamic> json) => Interview(
      characterName: json['characterName'] as String?,
      userName: json['userName'] as String,
      userDesc: json['userDesc'] as String,
      topics:
          (json['topics'] as List<dynamic>).map((e) => e as String).toList(),
      contentStarter: json['contentStarter'] as String,
      contentType: json['contentType'] as String,
      title: json['title'] as String,
    )
      ..id = json['id'] as String
      ..repeat = json['repeat'] as String
      ..time = DateTime.parse(json['time'] as String)
      ..messages = (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList()
      ..currentMessages = (json['currentMessages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList()
      ..status = json['status'] as String;

Map<String, dynamic> _$InterviewToJson(Interview instance) => <String, dynamic>{
      'id': instance.id,
      'characterName': instance.characterName,
      'topics': instance.topics,
      'contentType': instance.contentType,
      'contentStarter': instance.contentStarter,
      'title': instance.title,
      'repeat': instance.repeat,
      'time': instance.time.toIso8601String(),
      'messages': instance.messages,
      'currentMessages': instance.currentMessages,
      'status': instance.status,
      'userName': instance.userName,
      'userDesc': instance.userDesc,
    };
