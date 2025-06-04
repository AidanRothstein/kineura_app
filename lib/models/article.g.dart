// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArticleImpl _$$ArticleImplFromJson(Map<String, dynamic> json) =>
    _$ArticleImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      imageUrl: json['imageUrl'] as String?,
      summary: json['summary'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      readTime: json['readTime'] as int? ?? 0,
      isPublished: json['isPublished'] as bool? ?? false,
    );

Map<String, dynamic> _$$ArticleImplToJson(_$ArticleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'author': instance.author,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'imageUrl': instance.imageUrl,
      'summary': instance.summary,
      'tags': instance.tags,
      'readTime': instance.readTime,
      'isPublished': instance.isPublished,
    };

_$ArticleUploadImpl _$$ArticleUploadImplFromJson(Map<String, dynamic> json) =>
    _$ArticleUploadImpl(
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      imageUrl: json['imageUrl'] as String?,
      summary: json['summary'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      readTime: json['readTime'] as int? ?? 0,
      isPublished: json['isPublished'] as bool? ?? true,
    );

Map<String, dynamic> _$$ArticleUploadImplToJson(_$ArticleUploadImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'author': instance.author,
      'imageUrl': instance.imageUrl,
      'summary': instance.summary,
      'tags': instance.tags,
      'readTime': instance.readTime,
      'isPublished': instance.isPublished,
    };
