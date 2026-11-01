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

/// Records the team's signature agreeing to the score for one table in a match.
/// The team is resolved server side from the table assignment.
class SubmitSignatureRequest extends $pb.GeneratedMessage {
  factory SubmitSignatureRequest({
    $core.String? matchId,
    $core.String? tableId,
    $core.List<$core.int>? signaturePng,
  }) {
    final result = create();
    if (matchId != null) result.matchId = matchId;
    if (tableId != null) result.tableId = tableId;
    if (signaturePng != null) result.signaturePng = signaturePng;
    return result;
  }

  SubmitSignatureRequest._();

  factory SubmitSignatureRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubmitSignatureRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitSignatureRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'matchId')
    ..aOS(2, _omitFieldNames ? '' : 'tableId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'signaturePng', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitSignatureRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitSignatureRequest copyWith(
          void Function(SubmitSignatureRequest) updates) =>
      super.copyWith((message) => updates(message as SubmitSignatureRequest))
          as SubmitSignatureRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitSignatureRequest create() => SubmitSignatureRequest._();
  @$core.override
  SubmitSignatureRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubmitSignatureRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitSignatureRequest>(create);
  static SubmitSignatureRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get matchId => $_getSZ(0);
  @$pb.TagNumber(1)
  set matchId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMatchId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMatchId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tableId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tableId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTableId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTableId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get signaturePng => $_getN(2);
  @$pb.TagNumber(3)
  set signaturePng($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSignaturePng() => $_has(2);
  @$pb.TagNumber(3)
  void clearSignaturePng() => $_clearField(3);
}

class SubmitSignatureResponse extends $pb.GeneratedMessage {
  factory SubmitSignatureResponse() => create();

  SubmitSignatureResponse._();

  factory SubmitSignatureResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubmitSignatureResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitSignatureResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitSignatureResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitSignatureResponse copyWith(
          void Function(SubmitSignatureResponse) updates) =>
      super.copyWith((message) => updates(message as SubmitSignatureResponse))
          as SubmitSignatureResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitSignatureResponse create() => SubmitSignatureResponse._();
  @$core.override
  SubmitSignatureResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubmitSignatureResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitSignatureResponse>(create);
  static SubmitSignatureResponse? _defaultInstance;
}

class GetSignatureRequest extends $pb.GeneratedMessage {
  factory GetSignatureRequest({
    $core.String? matchId,
    $core.String? tableId,
  }) {
    final result = create();
    if (matchId != null) result.matchId = matchId;
    if (tableId != null) result.tableId = tableId;
    return result;
  }

  GetSignatureRequest._();

  factory GetSignatureRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSignatureRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSignatureRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'matchId')
    ..aOS(2, _omitFieldNames ? '' : 'tableId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSignatureRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSignatureRequest copyWith(void Function(GetSignatureRequest) updates) =>
      super.copyWith((message) => updates(message as GetSignatureRequest))
          as GetSignatureRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSignatureRequest create() => GetSignatureRequest._();
  @$core.override
  GetSignatureRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSignatureRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSignatureRequest>(create);
  static GetSignatureRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get matchId => $_getSZ(0);
  @$pb.TagNumber(1)
  set matchId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMatchId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMatchId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tableId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tableId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTableId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTableId() => $_clearField(2);
}

class GetSignatureResponse extends $pb.GeneratedMessage {
  factory GetSignatureResponse({
    $1.TeamSignature? signature,
  }) {
    final result = create();
    if (signature != null) result.signature = signature;
    return result;
  }

  GetSignatureResponse._();

  factory GetSignatureResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSignatureResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSignatureResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..aOM<$1.TeamSignature>(1, _omitFieldNames ? '' : 'signature',
        subBuilder: $1.TeamSignature.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSignatureResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSignatureResponse copyWith(void Function(GetSignatureResponse) updates) =>
      super.copyWith((message) => updates(message as GetSignatureResponse))
          as GetSignatureResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSignatureResponse create() => GetSignatureResponse._();
  @$core.override
  GetSignatureResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSignatureResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSignatureResponse>(create);
  static GetSignatureResponse? _defaultInstance;

  /// Unset if the team has not signed yet
  @$pb.TagNumber(1)
  $1.TeamSignature get signature => $_getN(0);
  @$pb.TagNumber(1)
  set signature($1.TeamSignature value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSignature() => $_has(0);
  @$pb.TagNumber(1)
  void clearSignature() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.TeamSignature ensureSignature() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
