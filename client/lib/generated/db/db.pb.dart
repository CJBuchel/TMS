// This is a generated file - do not edit.
//
// Generated from db/db.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../common/common.pb.dart' as $0;
import 'db.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'db.pbenum.dart';

class Secret extends $pb.GeneratedMessage {
  factory Secret({
    $core.List<$core.int>? secretBytes,
  }) {
    final result = create();
    if (secretBytes != null) result.secretBytes = secretBytes;
    return result;
  }

  Secret._();

  factory Secret.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Secret.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Secret',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.db'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'secretBytes', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secret clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secret copyWith(void Function(Secret) updates) =>
      super.copyWith((message) => updates(message as Secret)) as Secret;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Secret create() => Secret._();
  @$core.override
  Secret createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Secret getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Secret>(create);
  static Secret? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get secretBytes => $_getN(0);
  @$pb.TagNumber(1)
  set secretBytes($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSecretBytes() => $_has(0);
  @$pb.TagNumber(1)
  void clearSecretBytes() => $_clearField(1);
}

class User extends $pb.GeneratedMessage {
  factory User({
    $core.String? username,
    $core.String? password,
    $core.Iterable<$0.Role>? roles,
  }) {
    final result = create();
    if (username != null) result.username = username;
    if (password != null) result.password = password;
    if (roles != null) result.roles.addAll(roles);
    return result;
  }

  User._();

  factory User.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory User.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'User',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..pc<$0.Role>(3, _omitFieldNames ? '' : 'roles', $pb.PbFieldType.KE,
        valueOf: $0.Role.valueOf,
        enumValues: $0.Role.values,
        defaultEnumValue: $0.Role.ADMIN)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User copyWith(void Function(User) updates) =>
      super.copyWith((message) => updates(message as User)) as User;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  @$core.override
  User createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static User getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$0.Role> get roles => $_getList(2);
}

class Tournament extends $pb.GeneratedMessage {
  factory Tournament({
    $core.bool? bootstrapped,
    $core.String? name,
    $core.int? backupInterval,
    $core.int? retainBackups,
    $core.int? endGameTimerTrigger,
    $core.int? gameTimerLength,
    Season? season,
    $core.String? eventKey,
  }) {
    final result = create();
    if (bootstrapped != null) result.bootstrapped = bootstrapped;
    if (name != null) result.name = name;
    if (backupInterval != null) result.backupInterval = backupInterval;
    if (retainBackups != null) result.retainBackups = retainBackups;
    if (endGameTimerTrigger != null)
      result.endGameTimerTrigger = endGameTimerTrigger;
    if (gameTimerLength != null) result.gameTimerLength = gameTimerLength;
    if (season != null) result.season = season;
    if (eventKey != null) result.eventKey = eventKey;
    return result;
  }

  Tournament._();

  factory Tournament.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Tournament.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Tournament',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.db'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'bootstrapped')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'backupInterval',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'retainBackups',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'endGameTimerTrigger',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'gameTimerLength',
        fieldType: $pb.PbFieldType.OU3)
    ..aE<Season>(7, _omitFieldNames ? '' : 'season', enumValues: Season.values)
    ..aOS(8, _omitFieldNames ? '' : 'eventKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tournament clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tournament copyWith(void Function(Tournament) updates) =>
      super.copyWith((message) => updates(message as Tournament)) as Tournament;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tournament create() => Tournament._();
  @$core.override
  Tournament createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Tournament getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Tournament>(create);
  static Tournament? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get bootstrapped => $_getBF(0);
  @$pb.TagNumber(1)
  set bootstrapped($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBootstrapped() => $_has(0);
  @$pb.TagNumber(1)
  void clearBootstrapped() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get backupInterval => $_getIZ(2);
  @$pb.TagNumber(3)
  set backupInterval($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBackupInterval() => $_has(2);
  @$pb.TagNumber(3)
  void clearBackupInterval() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get retainBackups => $_getIZ(3);
  @$pb.TagNumber(4)
  set retainBackups($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRetainBackups() => $_has(3);
  @$pb.TagNumber(4)
  void clearRetainBackups() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get endGameTimerTrigger => $_getIZ(4);
  @$pb.TagNumber(5)
  set endGameTimerTrigger($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEndGameTimerTrigger() => $_has(4);
  @$pb.TagNumber(5)
  void clearEndGameTimerTrigger() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get gameTimerLength => $_getIZ(5);
  @$pb.TagNumber(6)
  set gameTimerLength($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGameTimerLength() => $_has(5);
  @$pb.TagNumber(6)
  void clearGameTimerLength() => $_clearField(6);

  @$pb.TagNumber(7)
  Season get season => $_getN(6);
  @$pb.TagNumber(7)
  set season(Season value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasSeason() => $_has(6);
  @$pb.TagNumber(7)
  void clearSeason() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get eventKey => $_getSZ(7);
  @$pb.TagNumber(8)
  set eventKey($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEventKey() => $_has(7);
  @$pb.TagNumber(8)
  void clearEventKey() => $_clearField(8);
}

class Team extends $pb.GeneratedMessage {
  factory Team({
    $core.String? teamNumber,
    $core.String? name,
    $core.String? affiliation,
  }) {
    final result = create();
    if (teamNumber != null) result.teamNumber = teamNumber;
    if (name != null) result.name = name;
    if (affiliation != null) result.affiliation = affiliation;
    return result;
  }

  Team._();

  factory Team.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Team.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Team',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'teamNumber')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'affiliation')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Team clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Team copyWith(void Function(Team) updates) =>
      super.copyWith((message) => updates(message as Team)) as Team;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Team create() => Team._();
  @$core.override
  Team createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Team getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Team>(create);
  static Team? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get teamNumber => $_getSZ(0);
  @$pb.TagNumber(1)
  set teamNumber($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTeamNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearTeamNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get affiliation => $_getSZ(2);
  @$pb.TagNumber(3)
  set affiliation($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAffiliation() => $_has(2);
  @$pb.TagNumber(3)
  void clearAffiliation() => $_clearField(3);
}

class TableAssignment extends $pb.GeneratedMessage {
  factory TableAssignment({
    $core.String? tableId,
    $core.String? teamId,
    $core.bool? scoreSubmitted,
  }) {
    final result = create();
    if (tableId != null) result.tableId = tableId;
    if (teamId != null) result.teamId = teamId;
    if (scoreSubmitted != null) result.scoreSubmitted = scoreSubmitted;
    return result;
  }

  TableAssignment._();

  factory TableAssignment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TableAssignment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TableAssignment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tableId')
    ..aOS(2, _omitFieldNames ? '' : 'teamId')
    ..aOB(3, _omitFieldNames ? '' : 'scoreSubmitted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TableAssignment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TableAssignment copyWith(void Function(TableAssignment) updates) =>
      super.copyWith((message) => updates(message as TableAssignment))
          as TableAssignment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TableAssignment create() => TableAssignment._();
  @$core.override
  TableAssignment createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TableAssignment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TableAssignment>(create);
  static TableAssignment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tableId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tableId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTableId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTableId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get teamId => $_getSZ(1);
  @$pb.TagNumber(2)
  set teamId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTeamId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTeamId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get scoreSubmitted => $_getBF(2);
  @$pb.TagNumber(3)
  set scoreSubmitted($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScoreSubmitted() => $_has(2);
  @$pb.TagNumber(3)
  void clearScoreSubmitted() => $_clearField(3);
}

class GameMatch extends $pb.GeneratedMessage {
  factory GameMatch({
    $core.String? matchNumber,
    $0.TmsDateTime? startTime,
    $0.TmsDateTime? endTime,
    $core.Iterable<TableAssignment>? assignments,
    $core.bool? completed,
    MatchType? matchType,
  }) {
    final result = create();
    if (matchNumber != null) result.matchNumber = matchNumber;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (assignments != null) result.assignments.addAll(assignments);
    if (completed != null) result.completed = completed;
    if (matchType != null) result.matchType = matchType;
    return result;
  }

  GameMatch._();

  factory GameMatch.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GameMatch.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GameMatch',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'matchNumber')
    ..aOM<$0.TmsDateTime>(2, _omitFieldNames ? '' : 'startTime',
        subBuilder: $0.TmsDateTime.create)
    ..aOM<$0.TmsDateTime>(3, _omitFieldNames ? '' : 'endTime',
        subBuilder: $0.TmsDateTime.create)
    ..pPM<TableAssignment>(4, _omitFieldNames ? '' : 'assignments',
        subBuilder: TableAssignment.create)
    ..aOB(5, _omitFieldNames ? '' : 'completed')
    ..aE<MatchType>(6, _omitFieldNames ? '' : 'matchType',
        enumValues: MatchType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GameMatch clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GameMatch copyWith(void Function(GameMatch) updates) =>
      super.copyWith((message) => updates(message as GameMatch)) as GameMatch;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GameMatch create() => GameMatch._();
  @$core.override
  GameMatch createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GameMatch getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GameMatch>(create);
  static GameMatch? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get matchNumber => $_getSZ(0);
  @$pb.TagNumber(1)
  set matchNumber($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMatchNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearMatchNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.TmsDateTime get startTime => $_getN(1);
  @$pb.TagNumber(2)
  set startTime($0.TmsDateTime value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.TmsDateTime ensureStartTime() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.TmsDateTime get endTime => $_getN(2);
  @$pb.TagNumber(3)
  set endTime($0.TmsDateTime value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEndTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndTime() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.TmsDateTime ensureEndTime() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<TableAssignment> get assignments => $_getList(3);

  @$pb.TagNumber(5)
  $core.bool get completed => $_getBF(4);
  @$pb.TagNumber(5)
  set completed($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCompleted() => $_has(4);
  @$pb.TagNumber(5)
  void clearCompleted() => $_clearField(5);

  @$pb.TagNumber(6)
  MatchType get matchType => $_getN(5);
  @$pb.TagNumber(6)
  set matchType(MatchType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasMatchType() => $_has(5);
  @$pb.TagNumber(6)
  void clearMatchType() => $_clearField(6);
}

class PodAssignment extends $pb.GeneratedMessage {
  factory PodAssignment({
    $core.String? podId,
    $core.String? teamId,
    $core.bool? coreValuesSubmitted,
    $core.bool? innovationSubmitted,
    $core.bool? robotDesignSubmitted,
  }) {
    final result = create();
    if (podId != null) result.podId = podId;
    if (teamId != null) result.teamId = teamId;
    if (coreValuesSubmitted != null)
      result.coreValuesSubmitted = coreValuesSubmitted;
    if (innovationSubmitted != null)
      result.innovationSubmitted = innovationSubmitted;
    if (robotDesignSubmitted != null)
      result.robotDesignSubmitted = robotDesignSubmitted;
    return result;
  }

  PodAssignment._();

  factory PodAssignment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PodAssignment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PodAssignment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'podId')
    ..aOS(2, _omitFieldNames ? '' : 'teamId')
    ..aOB(3, _omitFieldNames ? '' : 'coreValuesSubmitted')
    ..aOB(4, _omitFieldNames ? '' : 'innovationSubmitted')
    ..aOB(5, _omitFieldNames ? '' : 'robotDesignSubmitted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PodAssignment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PodAssignment copyWith(void Function(PodAssignment) updates) =>
      super.copyWith((message) => updates(message as PodAssignment))
          as PodAssignment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PodAssignment create() => PodAssignment._();
  @$core.override
  PodAssignment createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PodAssignment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PodAssignment>(create);
  static PodAssignment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get podId => $_getSZ(0);
  @$pb.TagNumber(1)
  set podId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPodId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPodId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get teamId => $_getSZ(1);
  @$pb.TagNumber(2)
  set teamId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTeamId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTeamId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get coreValuesSubmitted => $_getBF(2);
  @$pb.TagNumber(3)
  set coreValuesSubmitted($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCoreValuesSubmitted() => $_has(2);
  @$pb.TagNumber(3)
  void clearCoreValuesSubmitted() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get innovationSubmitted => $_getBF(3);
  @$pb.TagNumber(4)
  set innovationSubmitted($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInnovationSubmitted() => $_has(3);
  @$pb.TagNumber(4)
  void clearInnovationSubmitted() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get robotDesignSubmitted => $_getBF(4);
  @$pb.TagNumber(5)
  set robotDesignSubmitted($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRobotDesignSubmitted() => $_has(4);
  @$pb.TagNumber(5)
  void clearRobotDesignSubmitted() => $_clearField(5);
}

class JudgingSession extends $pb.GeneratedMessage {
  factory JudgingSession({
    $core.String? sessionNumber,
    $0.TmsDateTime? startTime,
    $0.TmsDateTime? endTime,
    $core.Iterable<PodAssignment>? assignments,
    $core.bool? complete,
  }) {
    final result = create();
    if (sessionNumber != null) result.sessionNumber = sessionNumber;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (assignments != null) result.assignments.addAll(assignments);
    if (complete != null) result.complete = complete;
    return result;
  }

  JudgingSession._();

  factory JudgingSession.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JudgingSession.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JudgingSession',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionNumber')
    ..aOM<$0.TmsDateTime>(2, _omitFieldNames ? '' : 'startTime',
        subBuilder: $0.TmsDateTime.create)
    ..aOM<$0.TmsDateTime>(3, _omitFieldNames ? '' : 'endTime',
        subBuilder: $0.TmsDateTime.create)
    ..pPM<PodAssignment>(4, _omitFieldNames ? '' : 'assignments',
        subBuilder: PodAssignment.create)
    ..aOB(5, _omitFieldNames ? '' : 'complete')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JudgingSession clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JudgingSession copyWith(void Function(JudgingSession) updates) =>
      super.copyWith((message) => updates(message as JudgingSession))
          as JudgingSession;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JudgingSession create() => JudgingSession._();
  @$core.override
  JudgingSession createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JudgingSession getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JudgingSession>(create);
  static JudgingSession? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionNumber => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionNumber($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.TmsDateTime get startTime => $_getN(1);
  @$pb.TagNumber(2)
  set startTime($0.TmsDateTime value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.TmsDateTime ensureStartTime() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.TmsDateTime get endTime => $_getN(2);
  @$pb.TagNumber(3)
  set endTime($0.TmsDateTime value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEndTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndTime() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.TmsDateTime ensureEndTime() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<PodAssignment> get assignments => $_getList(3);

  @$pb.TagNumber(5)
  $core.bool get complete => $_getBF(4);
  @$pb.TagNumber(5)
  set complete($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasComplete() => $_has(4);
  @$pb.TagNumber(5)
  void clearComplete() => $_clearField(5);
}

class TableName extends $pb.GeneratedMessage {
  factory TableName({
    $core.String? tableName,
  }) {
    final result = create();
    if (tableName != null) result.tableName = tableName;
    return result;
  }

  TableName._();

  factory TableName.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TableName.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TableName',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tableName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TableName clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TableName copyWith(void Function(TableName) updates) =>
      super.copyWith((message) => updates(message as TableName)) as TableName;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TableName create() => TableName._();
  @$core.override
  TableName createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TableName getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TableName>(create);
  static TableName? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tableName => $_getSZ(0);
  @$pb.TagNumber(1)
  set tableName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTableName() => $_has(0);
  @$pb.TagNumber(1)
  void clearTableName() => $_clearField(1);
}

class PodName extends $pb.GeneratedMessage {
  factory PodName({
    $core.String? podName,
  }) {
    final result = create();
    if (podName != null) result.podName = podName;
    return result;
  }

  PodName._();

  factory PodName.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PodName.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PodName',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.db'),
      createEmptyInstance: create)
    ..aOS(2, _omitFieldNames ? '' : 'podName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PodName clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PodName copyWith(void Function(PodName) updates) =>
      super.copyWith((message) => updates(message as PodName)) as PodName;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PodName create() => PodName._();
  @$core.override
  PodName createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PodName getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PodName>(create);
  static PodName? _defaultInstance;

  @$pb.TagNumber(2)
  $core.String get podName => $_getSZ(0);
  @$pb.TagNumber(2)
  set podName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(2)
  $core.bool hasPodName() => $_has(0);
  @$pb.TagNumber(2)
  void clearPodName() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
