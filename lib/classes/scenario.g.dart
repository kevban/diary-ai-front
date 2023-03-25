// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scenario _$ScenarioFromJson(Map<String, dynamic> json) => Scenario(
      setting: json['setting'] as String,
      userStart: json['userStart'] as bool? ?? false,
      title: json['title'] as String,
      description: json['description'] as String?,
      referenceStrength: (json['referenceStrength'] as num?)?.toDouble() ?? 0.5,
      instruction: json['instruction'] as String?,
      imgBase64: json['imgBase64'] as String?,
      id: json['id'] as String,
      downloads: json['downloads'] as int?,
    );

Map<String, dynamic> _$ScenarioToJson(Scenario instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'instruction': instance.instruction,
      'setting': instance.setting,
      'imgBase64': instance.imgBase64,
      'referenceStrength': instance.referenceStrength,
      'downloads': instance.downloads,
      'userStart': instance.userStart,
    };
