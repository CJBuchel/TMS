// This is a generated file - do not edit.
//
// Generated from api/schedule.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class UploadScheduleCsvRequest extends $pb.GeneratedMessage {
  factory UploadScheduleCsvRequest({
    $core.List<$core.int>? csvData,
  }) {
    final result = create();
    if (csvData != null) result.csvData = csvData;
    return result;
  }

  UploadScheduleCsvRequest._();

  factory UploadScheduleCsvRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadScheduleCsvRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadScheduleCsvRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'csvData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadScheduleCsvRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadScheduleCsvRequest copyWith(
          void Function(UploadScheduleCsvRequest) updates) =>
      super.copyWith((message) => updates(message as UploadScheduleCsvRequest))
          as UploadScheduleCsvRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadScheduleCsvRequest create() => UploadScheduleCsvRequest._();
  @$core.override
  UploadScheduleCsvRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadScheduleCsvRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadScheduleCsvRequest>(create);
  static UploadScheduleCsvRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get csvData => $_getN(0);
  @$pb.TagNumber(1)
  set csvData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCsvData() => $_has(0);
  @$pb.TagNumber(1)
  void clearCsvData() => $_clearField(1);
}

class UploadScheduleCsvResponse extends $pb.GeneratedMessage {
  factory UploadScheduleCsvResponse() => create();

  UploadScheduleCsvResponse._();

  factory UploadScheduleCsvResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadScheduleCsvResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadScheduleCsvResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadScheduleCsvResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadScheduleCsvResponse copyWith(
          void Function(UploadScheduleCsvResponse) updates) =>
      super.copyWith((message) => updates(message as UploadScheduleCsvResponse))
          as UploadScheduleCsvResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadScheduleCsvResponse create() => UploadScheduleCsvResponse._();
  @$core.override
  UploadScheduleCsvResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadScheduleCsvResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadScheduleCsvResponse>(create);
  static UploadScheduleCsvResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
