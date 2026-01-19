// This is a generated file - do not edit.
//
// Generated from api/team.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../db/db.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class TeamResponse extends $pb.GeneratedMessage {
  factory TeamResponse({
    $core.String? id,
    $1.Team? team,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (team != null) result.team = team;
    return result;
  }

  TeamResponse._();

  factory TeamResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TeamResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$1.Team>(2, _omitFieldNames ? '' : 'team', subBuilder: $1.Team.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamResponse copyWith(void Function(TeamResponse) updates) =>
      super.copyWith((message) => updates(message as TeamResponse))
          as TeamResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TeamResponse create() => TeamResponse._();
  @$core.override
  TeamResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TeamResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamResponse>(create);
  static TeamResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Team get team => $_getN(1);
  @$pb.TagNumber(2)
  set team($1.Team value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTeam() => $_has(1);
  @$pb.TagNumber(2)
  void clearTeam() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Team ensureTeam() => $_ensure(1);
}

class StreamTeamsRequest extends $pb.GeneratedMessage {
  factory StreamTeamsRequest() => create();

  StreamTeamsRequest._();

  factory StreamTeamsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamTeamsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamTeamsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTeamsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTeamsRequest copyWith(void Function(StreamTeamsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamTeamsRequest))
          as StreamTeamsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamTeamsRequest create() => StreamTeamsRequest._();
  @$core.override
  StreamTeamsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamTeamsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamTeamsRequest>(create);
  static StreamTeamsRequest? _defaultInstance;
}

class StreamTeamsResponse extends $pb.GeneratedMessage {
  factory StreamTeamsResponse({
    $core.Iterable<TeamResponse>? teams,
  }) {
    final result = create();
    if (teams != null) result.teams.addAll(teams);
    return result;
  }

  StreamTeamsResponse._();

  factory StreamTeamsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamTeamsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamTeamsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..pPM<TeamResponse>(1, _omitFieldNames ? '' : 'teams',
        subBuilder: TeamResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTeamsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTeamsResponse copyWith(void Function(StreamTeamsResponse) updates) =>
      super.copyWith((message) => updates(message as StreamTeamsResponse))
          as StreamTeamsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamTeamsResponse create() => StreamTeamsResponse._();
  @$core.override
  StreamTeamsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamTeamsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamTeamsResponse>(create);
  static StreamTeamsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TeamResponse> get teams => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
