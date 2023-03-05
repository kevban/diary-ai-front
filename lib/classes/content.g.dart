// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Content _$ContentFromJson(Map<String, dynamic> json) => Content(
      content: json['content'] as String,
      title: json['title'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$ContentToJson(Content instance) => <String, dynamic>{
      'content': instance.content,
      'title': instance.title,
      'timestamp': instance.timestamp.toIso8601String(),
    };
