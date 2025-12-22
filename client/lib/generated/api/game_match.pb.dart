// This is a generated file - do not edit.
//
// Generated from api/game_match.proto.

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

class GameMatchResponse extends $pb.GeneratedMessage {
  factory GameMatchResponse({
    $core.String? id,
    $1.GameMatch? gameMatch,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (gameMatch != null) result.gameMatch = gameMatch;
    return result;
  }

  GameMatchResponse._();

  factory GameMatchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GameMatchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GameMatchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$1.GameMatch>(2, _omitFieldNames ? '' : 'gameMatch',
        subBuilder: $1.GameMatch.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GameMatchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GameMatchResponse copyWith(void Function(GameMatchResponse) updates) =>
      super.copyWith((message) => updates(message as GameMatchResponse))
          as GameMatchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GameMatchResponse create() => GameMatchResponse._();
  @$core.override
  GameMatchResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GameMatchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GameMatchResponse>(create);
  static GameMatchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.GameMatch get gameMatch => $_getN(1);
  @$pb.TagNumber(2)
  set gameMatch($1.GameMatch value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasGameMatch() => $_has(1);
  @$pb.TagNumber(2)
  void clearGameMatch() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.GameMatch ensureGameMatch() => $_ensure(1);
}

class StreamMatchesRequest extends $pb.GeneratedMessage {
  factory StreamMatchesRequest() => create();

  StreamMatchesRequest._();

  factory StreamMatchesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamMatchesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamMatchesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamMatchesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamMatchesRequest copyWith(void Function(StreamMatchesRequest) updates) =>
      super.copyWith((message) => updates(message as StreamMatchesRequest))
          as StreamMatchesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamMatchesRequest create() => StreamMatchesRequest._();
  @$core.override
  StreamMatchesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamMatchesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamMatchesRequest>(create);
  static StreamMatchesRequest? _defaultInstance;
}

class StreamMatchesResponse extends $pb.GeneratedMessage {
  factory StreamMatchesResponse({
    $core.Iterable<GameMatchResponse>? gameMatches,
  }) {
    final result = create();
    if (gameMatches != null) result.gameMatches.addAll(gameMatches);
    return result;
  }

  StreamMatchesResponse._();

  factory StreamMatchesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamMatchesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamMatchesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..pPM<GameMatchResponse>(1, _omitFieldNames ? '' : 'gameMatches',
        subBuilder: GameMatchResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamMatchesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamMatchesResponse copyWith(
          void Function(StreamMatchesResponse) updates) =>
      super.copyWith((message) => updates(message as StreamMatchesResponse))
          as StreamMatchesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamMatchesResponse create() => StreamMatchesResponse._();
  @$core.override
  StreamMatchesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamMatchesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamMatchesResponse>(create);
  static StreamMatchesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GameMatchResponse> get gameMatches => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
