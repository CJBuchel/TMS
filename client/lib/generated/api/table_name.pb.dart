// This is a generated file - do not edit.
//
// Generated from api/table_name.proto.

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

class TableNameResponse extends $pb.GeneratedMessage {
  factory TableNameResponse({
    $core.String? id,
    $1.TableName? tableName,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tableName != null) result.tableName = tableName;
    return result;
  }

  TableNameResponse._();

  factory TableNameResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TableNameResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TableNameResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$1.TableName>(2, _omitFieldNames ? '' : 'tableName',
        subBuilder: $1.TableName.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TableNameResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TableNameResponse copyWith(void Function(TableNameResponse) updates) =>
      super.copyWith((message) => updates(message as TableNameResponse))
          as TableNameResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TableNameResponse create() => TableNameResponse._();
  @$core.override
  TableNameResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TableNameResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TableNameResponse>(create);
  static TableNameResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.TableName get tableName => $_getN(1);
  @$pb.TagNumber(2)
  set tableName($1.TableName value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTableName() => $_has(1);
  @$pb.TagNumber(2)
  void clearTableName() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.TableName ensureTableName() => $_ensure(1);
}

class StreamTableNamesRequest extends $pb.GeneratedMessage {
  factory StreamTableNamesRequest() => create();

  StreamTableNamesRequest._();

  factory StreamTableNamesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamTableNamesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamTableNamesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTableNamesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTableNamesRequest copyWith(
          void Function(StreamTableNamesRequest) updates) =>
      super.copyWith((message) => updates(message as StreamTableNamesRequest))
          as StreamTableNamesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamTableNamesRequest create() => StreamTableNamesRequest._();
  @$core.override
  StreamTableNamesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamTableNamesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamTableNamesRequest>(create);
  static StreamTableNamesRequest? _defaultInstance;
}

class StreamTableNamesResponse extends $pb.GeneratedMessage {
  factory StreamTableNamesResponse({
    $core.Iterable<TableNameResponse>? tableNames,
  }) {
    final result = create();
    if (tableNames != null) result.tableNames.addAll(tableNames);
    return result;
  }

  StreamTableNamesResponse._();

  factory StreamTableNamesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamTableNamesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamTableNamesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..pPM<TableNameResponse>(1, _omitFieldNames ? '' : 'tableNames',
        subBuilder: TableNameResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTableNamesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTableNamesResponse copyWith(
          void Function(StreamTableNamesResponse) updates) =>
      super.copyWith((message) => updates(message as StreamTableNamesResponse))
          as StreamTableNamesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamTableNamesResponse create() => StreamTableNamesResponse._();
  @$core.override
  StreamTableNamesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamTableNamesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamTableNamesResponse>(create);
  static StreamTableNamesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TableNameResponse> get tableNames => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
