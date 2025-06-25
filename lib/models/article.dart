/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'package:collection/collection.dart';


/** This is an auto generated class representing the Article type in your schema. */
class Article extends amplify_core.Model {
  static const classType = const _ArticleModelType();
  final String id;
  final String? _title;
  final String? _content;
  final String? _author;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;
  final String? _imageUrl;
  final String? _summary;
  final List<String>? _tags;
  final int? _readTime;
  final bool? _isPublished;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ArticleModelIdentifier get modelIdentifier {
      return ArticleModelIdentifier(
        id: id
      );
  }
  
  String get title {
    try {
      return _title!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get content {
    try {
      return _content!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get author {
    try {
      return _author!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get createdAt {
    try {
      return _createdAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get updatedAt {
    try {
      return _updatedAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get imageUrl {
    return _imageUrl;
  }
  
  String? get summary {
    return _summary;
  }
  
  List<String> get tags {
    try {
      return _tags!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get readTime {
    try {
      return _readTime!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get isPublished {
    try {
      return _isPublished!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  const Article._internal({required this.id, required title, required content, required author, required createdAt, required updatedAt, imageUrl, summary, required tags, required readTime, required isPublished}): _title = title, _content = content, _author = author, _createdAt = createdAt, _updatedAt = updatedAt, _imageUrl = imageUrl, _summary = summary, _tags = tags, _readTime = readTime, _isPublished = isPublished;
  
  factory Article({String? id, required String title, required String content, required String author, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt, String? imageUrl, String? summary, required List<String> tags, required int readTime, required bool isPublished}) {
    return Article._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      title: title,
      content: content,
      author: author,
      createdAt: createdAt,
      updatedAt: updatedAt,
      imageUrl: imageUrl,
      summary: summary,
      tags: tags != null ? List<String>.unmodifiable(tags) : tags,
      readTime: readTime,
      isPublished: isPublished);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Article &&
      id == other.id &&
      _title == other._title &&
      _content == other._content &&
      _author == other._author &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt &&
      _imageUrl == other._imageUrl &&
      _summary == other._summary &&
      DeepCollectionEquality().equals(_tags, other._tags) &&
      _readTime == other._readTime &&
      _isPublished == other._isPublished;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Article {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("content=" + "$_content" + ", ");
    buffer.write("author=" + "$_author" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null") + ", ");
    buffer.write("imageUrl=" + "$_imageUrl" + ", ");
    buffer.write("summary=" + "$_summary" + ", ");
    buffer.write("tags=" + (_tags != null ? _tags!.toString() : "null") + ", ");
    buffer.write("readTime=" + (_readTime != null ? _readTime!.toString() : "null") + ", ");
    buffer.write("isPublished=" + (_isPublished != null ? _isPublished!.toString() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Article copyWith({String? title, String? content, String? author, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt, String? imageUrl, String? summary, List<String>? tags, int? readTime, bool? isPublished}) {
    return Article._internal(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      summary: summary ?? this.summary,
      tags: tags ?? this.tags,
      readTime: readTime ?? this.readTime,
      isPublished: isPublished ?? this.isPublished);
  }
  
  Article copyWithModelFieldValues({
    ModelFieldValue<String>? title,
    ModelFieldValue<String>? content,
    ModelFieldValue<String>? author,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt,
    ModelFieldValue<String?>? imageUrl,
    ModelFieldValue<String?>? summary,
    ModelFieldValue<List<String>>? tags,
    ModelFieldValue<int>? readTime,
    ModelFieldValue<bool>? isPublished
  }) {
    return Article._internal(
      id: id,
      title: title == null ? this.title : title.value,
      content: content == null ? this.content : content.value,
      author: author == null ? this.author : author.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      imageUrl: imageUrl == null ? this.imageUrl : imageUrl.value,
      summary: summary == null ? this.summary : summary.value,
      tags: tags == null ? this.tags : tags.value,
      readTime: readTime == null ? this.readTime : readTime.value,
      isPublished: isPublished == null ? this.isPublished : isPublished.value
    );
  }
  
  Article.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _title = json['title'],
      _content = json['content'],
      _author = json['author'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null,
      _imageUrl = json['imageUrl'],
      _summary = json['summary'],
      _tags = json['tags']?.cast<String>(),
      _readTime = (json['readTime'] as num?)?.toInt(),
      _isPublished = json['isPublished'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'title': _title, 'content': _content, 'author': _author, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format(), 'imageUrl': _imageUrl, 'summary': _summary, 'tags': _tags, 'readTime': _readTime, 'isPublished': _isPublished
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'title': _title,
    'content': _content,
    'author': _author,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
    'imageUrl': _imageUrl,
    'summary': _summary,
    'tags': _tags,
    'readTime': _readTime,
    'isPublished': _isPublished
  };

  static final amplify_core.QueryModelIdentifier<ArticleModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ArticleModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final CONTENT = amplify_core.QueryField(fieldName: "content");
  static final AUTHOR = amplify_core.QueryField(fieldName: "author");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static final IMAGEURL = amplify_core.QueryField(fieldName: "imageUrl");
  static final SUMMARY = amplify_core.QueryField(fieldName: "summary");
  static final TAGS = amplify_core.QueryField(fieldName: "tags");
  static final READTIME = amplify_core.QueryField(fieldName: "readTime");
  static final ISPUBLISHED = amplify_core.QueryField(fieldName: "isPublished");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Article";
    modelSchemaDefinition.pluralName = "Articles";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        operations: const [
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "Editors" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Article.TITLE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Article.CONTENT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Article.AUTHOR,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Article.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Article.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Article.IMAGEURL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Article.SUMMARY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Article.TAGS,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Article.READTIME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Article.ISPUBLISHED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
  });
}

class _ArticleModelType extends amplify_core.ModelType<Article> {
  const _ArticleModelType();
  
  @override
  Article fromJson(Map<String, dynamic> jsonData) {
    return Article.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Article';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Article] in your schema.
 */
class ArticleModelIdentifier implements amplify_core.ModelIdentifier<Article> {
  final String id;

  /** Create an instance of ArticleModelIdentifier using [id] the primary key. */
  const ArticleModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'ArticleModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ArticleModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}