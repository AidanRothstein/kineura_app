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


/** This is an auto generated class representing the SleeveConfig type in your schema. */
class SleeveConfig extends amplify_core.Model {
  static const classType = const _SleeveConfigModelType();
  final String id;
  final String? _deviceType;
  final String? _side;
  final List<String>? _channelLabels;
  final String? _deviceNameContains;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  SleeveConfigModelIdentifier get modelIdentifier {
      return SleeveConfigModelIdentifier(
        id: id
      );
  }
  
  String get deviceType {
    try {
      return _deviceType!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get side {
    try {
      return _side!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get channelLabels {
    try {
      return _channelLabels!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get deviceNameContains {
    return _deviceNameContains;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const SleeveConfig._internal({required this.id, required deviceType, required side, required channelLabels, deviceNameContains, createdAt, updatedAt}): _deviceType = deviceType, _side = side, _channelLabels = channelLabels, _deviceNameContains = deviceNameContains, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory SleeveConfig({String? id, required String deviceType, required String side, required List<String> channelLabels, String? deviceNameContains}) {
    return SleeveConfig._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      deviceType: deviceType,
      side: side,
      channelLabels: channelLabels != null ? List<String>.unmodifiable(channelLabels) : channelLabels,
      deviceNameContains: deviceNameContains);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SleeveConfig &&
      id == other.id &&
      _deviceType == other._deviceType &&
      _side == other._side &&
      DeepCollectionEquality().equals(_channelLabels, other._channelLabels) &&
      _deviceNameContains == other._deviceNameContains;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("SleeveConfig {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("deviceType=" + "$_deviceType" + ", ");
    buffer.write("side=" + "$_side" + ", ");
    buffer.write("channelLabels=" + (_channelLabels != null ? _channelLabels!.toString() : "null") + ", ");
    buffer.write("deviceNameContains=" + "$_deviceNameContains" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  SleeveConfig copyWith({String? deviceType, String? side, List<String>? channelLabels, String? deviceNameContains}) {
    return SleeveConfig._internal(
      id: id,
      deviceType: deviceType ?? this.deviceType,
      side: side ?? this.side,
      channelLabels: channelLabels ?? this.channelLabels,
      deviceNameContains: deviceNameContains ?? this.deviceNameContains);
  }
  
  SleeveConfig copyWithModelFieldValues({
    ModelFieldValue<String>? deviceType,
    ModelFieldValue<String>? side,
    ModelFieldValue<List<String>>? channelLabels,
    ModelFieldValue<String?>? deviceNameContains
  }) {
    return SleeveConfig._internal(
      id: id,
      deviceType: deviceType == null ? this.deviceType : deviceType.value,
      side: side == null ? this.side : side.value,
      channelLabels: channelLabels == null ? this.channelLabels : channelLabels.value,
      deviceNameContains: deviceNameContains == null ? this.deviceNameContains : deviceNameContains.value
    );
  }
  
  SleeveConfig.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _deviceType = json['deviceType'],
      _side = json['side'],
      _channelLabels = json['channelLabels']?.cast<String>(),
      _deviceNameContains = json['deviceNameContains'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'deviceType': _deviceType, 'side': _side, 'channelLabels': _channelLabels, 'deviceNameContains': _deviceNameContains, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'deviceType': _deviceType,
    'side': _side,
    'channelLabels': _channelLabels,
    'deviceNameContains': _deviceNameContains,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<SleeveConfigModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<SleeveConfigModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final DEVICETYPE = amplify_core.QueryField(fieldName: "deviceType");
  static final SIDE = amplify_core.QueryField(fieldName: "side");
  static final CHANNELLABELS = amplify_core.QueryField(fieldName: "channelLabels");
  static final DEVICENAMECONTAINS = amplify_core.QueryField(fieldName: "deviceNameContains");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "SleeveConfig";
    modelSchemaDefinition.pluralName = "SleeveConfigs";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SleeveConfig.DEVICETYPE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SleeveConfig.SIDE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SleeveConfig.CHANNELLABELS,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SleeveConfig.DEVICENAMECONTAINS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _SleeveConfigModelType extends amplify_core.ModelType<SleeveConfig> {
  const _SleeveConfigModelType();
  
  @override
  SleeveConfig fromJson(Map<String, dynamic> jsonData) {
    return SleeveConfig.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'SleeveConfig';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [SleeveConfig] in your schema.
 */
class SleeveConfigModelIdentifier implements amplify_core.ModelIdentifier<SleeveConfig> {
  final String id;

  /** Create an instance of SleeveConfigModelIdentifier using [id] the primary key. */
  const SleeveConfigModelIdentifier({
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
  String toString() => 'SleeveConfigModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is SleeveConfigModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}