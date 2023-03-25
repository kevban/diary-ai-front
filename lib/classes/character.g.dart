// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Character _$CharacterFromJson(Map<String, dynamic> json) => Character(
      name: json['name'] as String,
      desc: json['desc'] as String,
      vocab: json['vocab'] as String,
      characteristics: (json['characteristics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imgBase64: json['imgBase64'] as String?,
      downloads: json['downloads'] as int?,
      id: json['id'] as String,
    );

Map<String, dynamic> _$CharacterToJson(Character instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'desc': instance.desc,
      'vocab': instance.vocab,
      'downloads': instance.downloads,
      'imgBase64': instance.imgBase64,
      'characteristics': instance.characteristics,
    };
