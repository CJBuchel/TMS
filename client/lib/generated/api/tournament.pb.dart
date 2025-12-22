// This is a generated file - do not edit.
//
// Generated from api/tournament.proto.

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

class GetTournamentRequest extends $pb.GeneratedMessage {
  factory GetTournamentRequest() => create();

  GetTournamentRequest._();

  factory GetTournamentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTournamentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTournamentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTournamentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTournamentRequest copyWith(void Function(GetTournamentRequest) updates) =>
      super.copyWith((message) => updates(message as GetTournamentRequest))
          as GetTournamentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTournamentRequest create() => GetTournamentRequest._();
  @$core.override
  GetTournamentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTournamentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTournamentRequest>(create);
  static GetTournamentRequest? _defaultInstance;
}

class GetTournamentResponse extends $pb.GeneratedMessage {
  factory GetTournamentResponse({
    $1.Tournament? tournament,
  }) {
    final result = create();
    if (tournament != null) result.tournament = tournament;
    return result;
  }

  GetTournamentResponse._();

  factory GetTournamentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTournamentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTournamentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..aOM<$1.Tournament>(1, _omitFieldNames ? '' : 'tournament',
        subBuilder: $1.Tournament.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTournamentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTournamentResponse copyWith(
          void Function(GetTournamentResponse) updates) =>
      super.copyWith((message) => updates(message as GetTournamentResponse))
          as GetTournamentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTournamentResponse create() => GetTournamentResponse._();
  @$core.override
  GetTournamentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTournamentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTournamentResponse>(create);
  static GetTournamentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Tournament get tournament => $_getN(0);
  @$pb.TagNumber(1)
  set tournament($1.Tournament value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTournament() => $_has(0);
  @$pb.TagNumber(1)
  void clearTournament() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Tournament ensureTournament() => $_ensure(0);
}

class SetTournamentRequest extends $pb.GeneratedMessage {
  factory SetTournamentRequest({
    $1.Tournament? tournament,
  }) {
    final result = create();
    if (tournament != null) result.tournament = tournament;
    return result;
  }

  SetTournamentRequest._();

  factory SetTournamentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetTournamentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetTournamentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..aOM<$1.Tournament>(1, _omitFieldNames ? '' : 'tournament',
        subBuilder: $1.Tournament.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTournamentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTournamentRequest copyWith(void Function(SetTournamentRequest) updates) =>
      super.copyWith((message) => updates(message as SetTournamentRequest))
          as SetTournamentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetTournamentRequest create() => SetTournamentRequest._();
  @$core.override
  SetTournamentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetTournamentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetTournamentRequest>(create);
  static SetTournamentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Tournament get tournament => $_getN(0);
  @$pb.TagNumber(1)
  set tournament($1.Tournament value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTournament() => $_has(0);
  @$pb.TagNumber(1)
  void clearTournament() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Tournament ensureTournament() => $_ensure(0);
}

class SetTournamentResponse extends $pb.GeneratedMessage {
  factory SetTournamentResponse() => create();

  SetTournamentResponse._();

  factory SetTournamentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetTournamentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetTournamentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTournamentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTournamentResponse copyWith(
          void Function(SetTournamentResponse) updates) =>
      super.copyWith((message) => updates(message as SetTournamentResponse))
          as SetTournamentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetTournamentResponse create() => SetTournamentResponse._();
  @$core.override
  SetTournamentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetTournamentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetTournamentResponse>(create);
  static SetTournamentResponse? _defaultInstance;
}

class StreamTournamentRequest extends $pb.GeneratedMessage {
  factory StreamTournamentRequest() => create();

  StreamTournamentRequest._();

  factory StreamTournamentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamTournamentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamTournamentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTournamentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTournamentRequest copyWith(
          void Function(StreamTournamentRequest) updates) =>
      super.copyWith((message) => updates(message as StreamTournamentRequest))
          as StreamTournamentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamTournamentRequest create() => StreamTournamentRequest._();
  @$core.override
  StreamTournamentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamTournamentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamTournamentRequest>(create);
  static StreamTournamentRequest? _defaultInstance;
}

class StreamTournamentResponse extends $pb.GeneratedMessage {
  factory StreamTournamentResponse({
    $1.Tournament? tournament,
  }) {
    final result = create();
    if (tournament != null) result.tournament = tournament;
    return result;
  }

  StreamTournamentResponse._();

  factory StreamTournamentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamTournamentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamTournamentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..aOM<$1.Tournament>(1, _omitFieldNames ? '' : 'tournament',
        subBuilder: $1.Tournament.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTournamentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTournamentResponse copyWith(
          void Function(StreamTournamentResponse) updates) =>
      super.copyWith((message) => updates(message as StreamTournamentResponse))
          as StreamTournamentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamTournamentResponse create() => StreamTournamentResponse._();
  @$core.override
  StreamTournamentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamTournamentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamTournamentResponse>(create);
  static StreamTournamentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Tournament get tournament => $_getN(0);
  @$pb.TagNumber(1)
  set tournament($1.Tournament value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTournament() => $_has(0);
  @$pb.TagNumber(1)
  void clearTournament() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Tournament ensureTournament() => $_ensure(0);
}

class DeleteTournamentRequest extends $pb.GeneratedMessage {
  factory DeleteTournamentRequest() => create();

  DeleteTournamentRequest._();

  factory DeleteTournamentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTournamentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTournamentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTournamentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTournamentRequest copyWith(
          void Function(DeleteTournamentRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteTournamentRequest))
          as DeleteTournamentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTournamentRequest create() => DeleteTournamentRequest._();
  @$core.override
  DeleteTournamentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTournamentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTournamentRequest>(create);
  static DeleteTournamentRequest? _defaultInstance;
}

class DeleteTournamentResponse extends $pb.GeneratedMessage {
  factory DeleteTournamentResponse() => create();

  DeleteTournamentResponse._();

  factory DeleteTournamentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTournamentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTournamentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTournamentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTournamentResponse copyWith(
          void Function(DeleteTournamentResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteTournamentResponse))
          as DeleteTournamentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTournamentResponse create() => DeleteTournamentResponse._();
  @$core.override
  DeleteTournamentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTournamentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTournamentResponse>(create);
  static DeleteTournamentResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
