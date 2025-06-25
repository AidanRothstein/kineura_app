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


/** This is an auto generated class representing the Session type in your schema. */
class Session extends amplify_core.Model {
  static const classType = const _SessionModelType();
  final String id;
  final String? _userID;
  final String? _owner;
  final amplify_core.TemporalDateTime? _timestamp;
  final int? _durationSeconds;
  final String? _emgS3Key;
  final String? _emgProcessedS3Key;
  final String? _imuS3Key;
  final String? _workoutType;
  final String? _notes;
  final double? _peakRMS;
  final double? _averageRMS;
  final double? _fatigueIndex;
  final double? _elasticityIndex;
  final double? _activationRatio;
  final double? _medianFrequency;
  final double? _meanFrequency;
  final double? _signalToNoiseRatio;
  final double? _baselineDrift;
  final double? _zeroCrossingRate;
  final double? _rateOfRise;
  final double? _rateOfFall;
  final double? _rfdAnalog;
  final double? _snrTimeRaw;
  final double? _snrTimeDenoised;
  final double? _snrFreqRaw;
  final double? _snrFreqDenoised;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  SessionModelIdentifier get modelIdentifier {
      return SessionModelIdentifier(
        id: id
      );
  }
  
  String get userID {
    try {
      return _userID!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get owner {
    try {
      return _owner!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get timestamp {
    try {
      return _timestamp!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int? get durationSeconds {
    return _durationSeconds;
  }
  
  String? get emgS3Key {
    return _emgS3Key;
  }
  
  String? get emgProcessedS3Key {
    return _emgProcessedS3Key;
  }
  
  String? get imuS3Key {
    return _imuS3Key;
  }
  
  String? get workoutType {
    return _workoutType;
  }
  
  String? get notes {
    return _notes;
  }
  
  double? get peakRMS {
    return _peakRMS;
  }
  
  double? get averageRMS {
    return _averageRMS;
  }
  
  double? get fatigueIndex {
    return _fatigueIndex;
  }
  
  double? get elasticityIndex {
    return _elasticityIndex;
  }
  
  double? get activationRatio {
    return _activationRatio;
  }
  
  double? get medianFrequency {
    return _medianFrequency;
  }
  
  double? get meanFrequency {
    return _meanFrequency;
  }
  
  double? get signalToNoiseRatio {
    return _signalToNoiseRatio;
  }
  
  double? get baselineDrift {
    return _baselineDrift;
  }
  
  double? get zeroCrossingRate {
    return _zeroCrossingRate;
  }
  
  double? get rateOfRise {
    return _rateOfRise;
  }
  
  double? get rateOfFall {
    return _rateOfFall;
  }
  
  double? get rfdAnalog {
    return _rfdAnalog;
  }
  
  double? get snrTimeRaw {
    return _snrTimeRaw;
  }
  
  double? get snrTimeDenoised {
    return _snrTimeDenoised;
  }
  
  double? get snrFreqRaw {
    return _snrFreqRaw;
  }
  
  double? get snrFreqDenoised {
    return _snrFreqDenoised;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Session._internal({required this.id, required userID, required owner, required timestamp, durationSeconds, emgS3Key, emgProcessedS3Key, imuS3Key, workoutType, notes, peakRMS, averageRMS, fatigueIndex, elasticityIndex, activationRatio, medianFrequency, meanFrequency, signalToNoiseRatio, baselineDrift, zeroCrossingRate, rateOfRise, rateOfFall, rfdAnalog, snrTimeRaw, snrTimeDenoised, snrFreqRaw, snrFreqDenoised, createdAt, updatedAt}): _userID = userID, _owner = owner, _timestamp = timestamp, _durationSeconds = durationSeconds, _emgS3Key = emgS3Key, _emgProcessedS3Key = emgProcessedS3Key, _imuS3Key = imuS3Key, _workoutType = workoutType, _notes = notes, _peakRMS = peakRMS, _averageRMS = averageRMS, _fatigueIndex = fatigueIndex, _elasticityIndex = elasticityIndex, _activationRatio = activationRatio, _medianFrequency = medianFrequency, _meanFrequency = meanFrequency, _signalToNoiseRatio = signalToNoiseRatio, _baselineDrift = baselineDrift, _zeroCrossingRate = zeroCrossingRate, _rateOfRise = rateOfRise, _rateOfFall = rateOfFall, _rfdAnalog = rfdAnalog, _snrTimeRaw = snrTimeRaw, _snrTimeDenoised = snrTimeDenoised, _snrFreqRaw = snrFreqRaw, _snrFreqDenoised = snrFreqDenoised, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Session({String? id, required String userID, required String owner, required amplify_core.TemporalDateTime timestamp, int? durationSeconds, String? emgS3Key, String? emgProcessedS3Key, String? imuS3Key, String? workoutType, String? notes, double? peakRMS, double? averageRMS, double? fatigueIndex, double? elasticityIndex, double? activationRatio, double? medianFrequency, double? meanFrequency, double? signalToNoiseRatio, double? baselineDrift, double? zeroCrossingRate, double? rateOfRise, double? rateOfFall, double? rfdAnalog, double? snrTimeRaw, double? snrTimeDenoised, double? snrFreqRaw, double? snrFreqDenoised}) {
    return Session._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      userID: userID,
      owner: owner,
      timestamp: timestamp,
      durationSeconds: durationSeconds,
      emgS3Key: emgS3Key,
      emgProcessedS3Key: emgProcessedS3Key,
      imuS3Key: imuS3Key,
      workoutType: workoutType,
      notes: notes,
      peakRMS: peakRMS,
      averageRMS: averageRMS,
      fatigueIndex: fatigueIndex,
      elasticityIndex: elasticityIndex,
      activationRatio: activationRatio,
      medianFrequency: medianFrequency,
      meanFrequency: meanFrequency,
      signalToNoiseRatio: signalToNoiseRatio,
      baselineDrift: baselineDrift,
      zeroCrossingRate: zeroCrossingRate,
      rateOfRise: rateOfRise,
      rateOfFall: rateOfFall,
      rfdAnalog: rfdAnalog,
      snrTimeRaw: snrTimeRaw,
      snrTimeDenoised: snrTimeDenoised,
      snrFreqRaw: snrFreqRaw,
      snrFreqDenoised: snrFreqDenoised);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Session &&
      id == other.id &&
      _userID == other._userID &&
      _owner == other._owner &&
      _timestamp == other._timestamp &&
      _durationSeconds == other._durationSeconds &&
      _emgS3Key == other._emgS3Key &&
      _emgProcessedS3Key == other._emgProcessedS3Key &&
      _imuS3Key == other._imuS3Key &&
      _workoutType == other._workoutType &&
      _notes == other._notes &&
      _peakRMS == other._peakRMS &&
      _averageRMS == other._averageRMS &&
      _fatigueIndex == other._fatigueIndex &&
      _elasticityIndex == other._elasticityIndex &&
      _activationRatio == other._activationRatio &&
      _medianFrequency == other._medianFrequency &&
      _meanFrequency == other._meanFrequency &&
      _signalToNoiseRatio == other._signalToNoiseRatio &&
      _baselineDrift == other._baselineDrift &&
      _zeroCrossingRate == other._zeroCrossingRate &&
      _rateOfRise == other._rateOfRise &&
      _rateOfFall == other._rateOfFall &&
      _rfdAnalog == other._rfdAnalog &&
      _snrTimeRaw == other._snrTimeRaw &&
      _snrTimeDenoised == other._snrTimeDenoised &&
      _snrFreqRaw == other._snrFreqRaw &&
      _snrFreqDenoised == other._snrFreqDenoised;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Session {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("userID=" + "$_userID" + ", ");
    buffer.write("owner=" + "$_owner" + ", ");
    buffer.write("timestamp=" + (_timestamp != null ? _timestamp!.format() : "null") + ", ");
    buffer.write("durationSeconds=" + (_durationSeconds != null ? _durationSeconds!.toString() : "null") + ", ");
    buffer.write("emgS3Key=" + "$_emgS3Key" + ", ");
    buffer.write("emgProcessedS3Key=" + "$_emgProcessedS3Key" + ", ");
    buffer.write("imuS3Key=" + "$_imuS3Key" + ", ");
    buffer.write("workoutType=" + "$_workoutType" + ", ");
    buffer.write("notes=" + "$_notes" + ", ");
    buffer.write("peakRMS=" + (_peakRMS != null ? _peakRMS!.toString() : "null") + ", ");
    buffer.write("averageRMS=" + (_averageRMS != null ? _averageRMS!.toString() : "null") + ", ");
    buffer.write("fatigueIndex=" + (_fatigueIndex != null ? _fatigueIndex!.toString() : "null") + ", ");
    buffer.write("elasticityIndex=" + (_elasticityIndex != null ? _elasticityIndex!.toString() : "null") + ", ");
    buffer.write("activationRatio=" + (_activationRatio != null ? _activationRatio!.toString() : "null") + ", ");
    buffer.write("medianFrequency=" + (_medianFrequency != null ? _medianFrequency!.toString() : "null") + ", ");
    buffer.write("meanFrequency=" + (_meanFrequency != null ? _meanFrequency!.toString() : "null") + ", ");
    buffer.write("signalToNoiseRatio=" + (_signalToNoiseRatio != null ? _signalToNoiseRatio!.toString() : "null") + ", ");
    buffer.write("baselineDrift=" + (_baselineDrift != null ? _baselineDrift!.toString() : "null") + ", ");
    buffer.write("zeroCrossingRate=" + (_zeroCrossingRate != null ? _zeroCrossingRate!.toString() : "null") + ", ");
    buffer.write("rateOfRise=" + (_rateOfRise != null ? _rateOfRise!.toString() : "null") + ", ");
    buffer.write("rateOfFall=" + (_rateOfFall != null ? _rateOfFall!.toString() : "null") + ", ");
    buffer.write("rfdAnalog=" + (_rfdAnalog != null ? _rfdAnalog!.toString() : "null") + ", ");
    buffer.write("snrTimeRaw=" + (_snrTimeRaw != null ? _snrTimeRaw!.toString() : "null") + ", ");
    buffer.write("snrTimeDenoised=" + (_snrTimeDenoised != null ? _snrTimeDenoised!.toString() : "null") + ", ");
    buffer.write("snrFreqRaw=" + (_snrFreqRaw != null ? _snrFreqRaw!.toString() : "null") + ", ");
    buffer.write("snrFreqDenoised=" + (_snrFreqDenoised != null ? _snrFreqDenoised!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Session copyWith({String? userID, String? owner, amplify_core.TemporalDateTime? timestamp, int? durationSeconds, String? emgS3Key, String? emgProcessedS3Key, String? imuS3Key, String? workoutType, String? notes, double? peakRMS, double? averageRMS, double? fatigueIndex, double? elasticityIndex, double? activationRatio, double? medianFrequency, double? meanFrequency, double? signalToNoiseRatio, double? baselineDrift, double? zeroCrossingRate, double? rateOfRise, double? rateOfFall, double? rfdAnalog, double? snrTimeRaw, double? snrTimeDenoised, double? snrFreqRaw, double? snrFreqDenoised}) {
    return Session._internal(
      id: id,
      userID: userID ?? this.userID,
      owner: owner ?? this.owner,
      timestamp: timestamp ?? this.timestamp,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      emgS3Key: emgS3Key ?? this.emgS3Key,
      emgProcessedS3Key: emgProcessedS3Key ?? this.emgProcessedS3Key,
      imuS3Key: imuS3Key ?? this.imuS3Key,
      workoutType: workoutType ?? this.workoutType,
      notes: notes ?? this.notes,
      peakRMS: peakRMS ?? this.peakRMS,
      averageRMS: averageRMS ?? this.averageRMS,
      fatigueIndex: fatigueIndex ?? this.fatigueIndex,
      elasticityIndex: elasticityIndex ?? this.elasticityIndex,
      activationRatio: activationRatio ?? this.activationRatio,
      medianFrequency: medianFrequency ?? this.medianFrequency,
      meanFrequency: meanFrequency ?? this.meanFrequency,
      signalToNoiseRatio: signalToNoiseRatio ?? this.signalToNoiseRatio,
      baselineDrift: baselineDrift ?? this.baselineDrift,
      zeroCrossingRate: zeroCrossingRate ?? this.zeroCrossingRate,
      rateOfRise: rateOfRise ?? this.rateOfRise,
      rateOfFall: rateOfFall ?? this.rateOfFall,
      rfdAnalog: rfdAnalog ?? this.rfdAnalog,
      snrTimeRaw: snrTimeRaw ?? this.snrTimeRaw,
      snrTimeDenoised: snrTimeDenoised ?? this.snrTimeDenoised,
      snrFreqRaw: snrFreqRaw ?? this.snrFreqRaw,
      snrFreqDenoised: snrFreqDenoised ?? this.snrFreqDenoised);
  }
  
  Session copyWithModelFieldValues({
    ModelFieldValue<String>? userID,
    ModelFieldValue<String>? owner,
    ModelFieldValue<amplify_core.TemporalDateTime>? timestamp,
    ModelFieldValue<int?>? durationSeconds,
    ModelFieldValue<String?>? emgS3Key,
    ModelFieldValue<String?>? emgProcessedS3Key,
    ModelFieldValue<String?>? imuS3Key,
    ModelFieldValue<String?>? workoutType,
    ModelFieldValue<String?>? notes,
    ModelFieldValue<double?>? peakRMS,
    ModelFieldValue<double?>? averageRMS,
    ModelFieldValue<double?>? fatigueIndex,
    ModelFieldValue<double?>? elasticityIndex,
    ModelFieldValue<double?>? activationRatio,
    ModelFieldValue<double?>? medianFrequency,
    ModelFieldValue<double?>? meanFrequency,
    ModelFieldValue<double?>? signalToNoiseRatio,
    ModelFieldValue<double?>? baselineDrift,
    ModelFieldValue<double?>? zeroCrossingRate,
    ModelFieldValue<double?>? rateOfRise,
    ModelFieldValue<double?>? rateOfFall,
    ModelFieldValue<double?>? rfdAnalog,
    ModelFieldValue<double?>? snrTimeRaw,
    ModelFieldValue<double?>? snrTimeDenoised,
    ModelFieldValue<double?>? snrFreqRaw,
    ModelFieldValue<double?>? snrFreqDenoised
  }) {
    return Session._internal(
      id: id,
      userID: userID == null ? this.userID : userID.value,
      owner: owner == null ? this.owner : owner.value,
      timestamp: timestamp == null ? this.timestamp : timestamp.value,
      durationSeconds: durationSeconds == null ? this.durationSeconds : durationSeconds.value,
      emgS3Key: emgS3Key == null ? this.emgS3Key : emgS3Key.value,
      emgProcessedS3Key: emgProcessedS3Key == null ? this.emgProcessedS3Key : emgProcessedS3Key.value,
      imuS3Key: imuS3Key == null ? this.imuS3Key : imuS3Key.value,
      workoutType: workoutType == null ? this.workoutType : workoutType.value,
      notes: notes == null ? this.notes : notes.value,
      peakRMS: peakRMS == null ? this.peakRMS : peakRMS.value,
      averageRMS: averageRMS == null ? this.averageRMS : averageRMS.value,
      fatigueIndex: fatigueIndex == null ? this.fatigueIndex : fatigueIndex.value,
      elasticityIndex: elasticityIndex == null ? this.elasticityIndex : elasticityIndex.value,
      activationRatio: activationRatio == null ? this.activationRatio : activationRatio.value,
      medianFrequency: medianFrequency == null ? this.medianFrequency : medianFrequency.value,
      meanFrequency: meanFrequency == null ? this.meanFrequency : meanFrequency.value,
      signalToNoiseRatio: signalToNoiseRatio == null ? this.signalToNoiseRatio : signalToNoiseRatio.value,
      baselineDrift: baselineDrift == null ? this.baselineDrift : baselineDrift.value,
      zeroCrossingRate: zeroCrossingRate == null ? this.zeroCrossingRate : zeroCrossingRate.value,
      rateOfRise: rateOfRise == null ? this.rateOfRise : rateOfRise.value,
      rateOfFall: rateOfFall == null ? this.rateOfFall : rateOfFall.value,
      rfdAnalog: rfdAnalog == null ? this.rfdAnalog : rfdAnalog.value,
      snrTimeRaw: snrTimeRaw == null ? this.snrTimeRaw : snrTimeRaw.value,
      snrTimeDenoised: snrTimeDenoised == null ? this.snrTimeDenoised : snrTimeDenoised.value,
      snrFreqRaw: snrFreqRaw == null ? this.snrFreqRaw : snrFreqRaw.value,
      snrFreqDenoised: snrFreqDenoised == null ? this.snrFreqDenoised : snrFreqDenoised.value
    );
  }
  
  Session.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _userID = json['userID'],
      _owner = json['owner'],
      _timestamp = json['timestamp'] != null ? amplify_core.TemporalDateTime.fromString(json['timestamp']) : null,
      _durationSeconds = (json['durationSeconds'] as num?)?.toInt(),
      _emgS3Key = json['emgS3Key'],
      _emgProcessedS3Key = json['emgProcessedS3Key'],
      _imuS3Key = json['imuS3Key'],
      _workoutType = json['workoutType'],
      _notes = json['notes'],
      _peakRMS = (json['peakRMS'] as num?)?.toDouble(),
      _averageRMS = (json['averageRMS'] as num?)?.toDouble(),
      _fatigueIndex = (json['fatigueIndex'] as num?)?.toDouble(),
      _elasticityIndex = (json['elasticityIndex'] as num?)?.toDouble(),
      _activationRatio = (json['activationRatio'] as num?)?.toDouble(),
      _medianFrequency = (json['medianFrequency'] as num?)?.toDouble(),
      _meanFrequency = (json['meanFrequency'] as num?)?.toDouble(),
      _signalToNoiseRatio = (json['signalToNoiseRatio'] as num?)?.toDouble(),
      _baselineDrift = (json['baselineDrift'] as num?)?.toDouble(),
      _zeroCrossingRate = (json['zeroCrossingRate'] as num?)?.toDouble(),
      _rateOfRise = (json['rateOfRise'] as num?)?.toDouble(),
      _rateOfFall = (json['rateOfFall'] as num?)?.toDouble(),
      _rfdAnalog = (json['rfdAnalog'] as num?)?.toDouble(),
      _snrTimeRaw = (json['snrTimeRaw'] as num?)?.toDouble(),
      _snrTimeDenoised = (json['snrTimeDenoised'] as num?)?.toDouble(),
      _snrFreqRaw = (json['snrFreqRaw'] as num?)?.toDouble(),
      _snrFreqDenoised = (json['snrFreqDenoised'] as num?)?.toDouble(),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'userID': _userID, 'owner': _owner, 'timestamp': _timestamp?.format(), 'durationSeconds': _durationSeconds, 'emgS3Key': _emgS3Key, 'emgProcessedS3Key': _emgProcessedS3Key, 'imuS3Key': _imuS3Key, 'workoutType': _workoutType, 'notes': _notes, 'peakRMS': _peakRMS, 'averageRMS': _averageRMS, 'fatigueIndex': _fatigueIndex, 'elasticityIndex': _elasticityIndex, 'activationRatio': _activationRatio, 'medianFrequency': _medianFrequency, 'meanFrequency': _meanFrequency, 'signalToNoiseRatio': _signalToNoiseRatio, 'baselineDrift': _baselineDrift, 'zeroCrossingRate': _zeroCrossingRate, 'rateOfRise': _rateOfRise, 'rateOfFall': _rateOfFall, 'rfdAnalog': _rfdAnalog, 'snrTimeRaw': _snrTimeRaw, 'snrTimeDenoised': _snrTimeDenoised, 'snrFreqRaw': _snrFreqRaw, 'snrFreqDenoised': _snrFreqDenoised, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'userID': _userID,
    'owner': _owner,
    'timestamp': _timestamp,
    'durationSeconds': _durationSeconds,
    'emgS3Key': _emgS3Key,
    'emgProcessedS3Key': _emgProcessedS3Key,
    'imuS3Key': _imuS3Key,
    'workoutType': _workoutType,
    'notes': _notes,
    'peakRMS': _peakRMS,
    'averageRMS': _averageRMS,
    'fatigueIndex': _fatigueIndex,
    'elasticityIndex': _elasticityIndex,
    'activationRatio': _activationRatio,
    'medianFrequency': _medianFrequency,
    'meanFrequency': _meanFrequency,
    'signalToNoiseRatio': _signalToNoiseRatio,
    'baselineDrift': _baselineDrift,
    'zeroCrossingRate': _zeroCrossingRate,
    'rateOfRise': _rateOfRise,
    'rateOfFall': _rateOfFall,
    'rfdAnalog': _rfdAnalog,
    'snrTimeRaw': _snrTimeRaw,
    'snrTimeDenoised': _snrTimeDenoised,
    'snrFreqRaw': _snrFreqRaw,
    'snrFreqDenoised': _snrFreqDenoised,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<SessionModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<SessionModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USERID = amplify_core.QueryField(fieldName: "userID");
  static final OWNER = amplify_core.QueryField(fieldName: "owner");
  static final TIMESTAMP = amplify_core.QueryField(fieldName: "timestamp");
  static final DURATIONSECONDS = amplify_core.QueryField(fieldName: "durationSeconds");
  static final EMGS3KEY = amplify_core.QueryField(fieldName: "emgS3Key");
  static final EMGPROCESSEDS3KEY = amplify_core.QueryField(fieldName: "emgProcessedS3Key");
  static final IMUS3KEY = amplify_core.QueryField(fieldName: "imuS3Key");
  static final WORKOUTTYPE = amplify_core.QueryField(fieldName: "workoutType");
  static final NOTES = amplify_core.QueryField(fieldName: "notes");
  static final PEAKRMS = amplify_core.QueryField(fieldName: "peakRMS");
  static final AVERAGERMS = amplify_core.QueryField(fieldName: "averageRMS");
  static final FATIGUEINDEX = amplify_core.QueryField(fieldName: "fatigueIndex");
  static final ELASTICITYINDEX = amplify_core.QueryField(fieldName: "elasticityIndex");
  static final ACTIVATIONRATIO = amplify_core.QueryField(fieldName: "activationRatio");
  static final MEDIANFREQUENCY = amplify_core.QueryField(fieldName: "medianFrequency");
  static final MEANFREQUENCY = amplify_core.QueryField(fieldName: "meanFrequency");
  static final SIGNALTONOISERATIO = amplify_core.QueryField(fieldName: "signalToNoiseRatio");
  static final BASELINEDRIFT = amplify_core.QueryField(fieldName: "baselineDrift");
  static final ZEROCROSSINGRATE = amplify_core.QueryField(fieldName: "zeroCrossingRate");
  static final RATEOFRISE = amplify_core.QueryField(fieldName: "rateOfRise");
  static final RATEOFFALL = amplify_core.QueryField(fieldName: "rateOfFall");
  static final RFDANALOG = amplify_core.QueryField(fieldName: "rfdAnalog");
  static final SNRTIMERAW = amplify_core.QueryField(fieldName: "snrTimeRaw");
  static final SNRTIMEDENOISED = amplify_core.QueryField(fieldName: "snrTimeDenoised");
  static final SNRFREQRAW = amplify_core.QueryField(fieldName: "snrFreqRaw");
  static final SNRFREQDENOISED = amplify_core.QueryField(fieldName: "snrFreqDenoised");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Session";
    modelSchemaDefinition.pluralName = "Sessions";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        provider: amplify_core.AuthRuleProvider.IAM,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        provider: amplify_core.AuthRuleProvider.APIKEY,
        operations: const [
          amplify_core.ModelOperation.CREATE
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.USERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.OWNER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.TIMESTAMP,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.DURATIONSECONDS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.EMGS3KEY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.EMGPROCESSEDS3KEY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.IMUS3KEY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.WORKOUTTYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.NOTES,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.PEAKRMS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.AVERAGERMS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.FATIGUEINDEX,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.ELASTICITYINDEX,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.ACTIVATIONRATIO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.MEDIANFREQUENCY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.MEANFREQUENCY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.SIGNALTONOISERATIO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.BASELINEDRIFT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.ZEROCROSSINGRATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.RATEOFRISE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.RATEOFFALL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.RFDANALOG,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.SNRTIMERAW,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.SNRTIMEDENOISED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.SNRFREQRAW,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Session.SNRFREQDENOISED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
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

class _SessionModelType extends amplify_core.ModelType<Session> {
  const _SessionModelType();
  
  @override
  Session fromJson(Map<String, dynamic> jsonData) {
    return Session.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Session';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Session] in your schema.
 */
class SessionModelIdentifier implements amplify_core.ModelIdentifier<Session> {
  final String id;

  /** Create an instance of SessionModelIdentifier using [id] the primary key. */
  const SessionModelIdentifier({
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
  String toString() => 'SessionModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is SessionModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}