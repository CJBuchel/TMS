// This is a generated file - do not edit.
//
// Generated from api/integrity.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../common/common.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class GetIntegrityMessagesRequest extends $pb.GeneratedMessage {
  factory GetIntegrityMessagesRequest() => create();

  GetIntegrityMessagesRequest._();

  factory GetIntegrityMessagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetIntegrityMessagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetIntegrityMessagesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIntegrityMessagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIntegrityMessagesRequest copyWith(
          void Function(GetIntegrityMessagesRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetIntegrityMessagesRequest))
          as GetIntegrityMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetIntegrityMessagesRequest create() =>
      GetIntegrityMessagesRequest._();
  @$core.override
  GetIntegrityMessagesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetIntegrityMessagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetIntegrityMessagesRequest>(create);
  static GetIntegrityMessagesRequest? _defaultInstance;
}

class GetIntegrityMessagesResponse extends $pb.GeneratedMessage {
  factory GetIntegrityMessagesResponse({
    $core.Iterable<$1.IntegrityMessage>? messages,
  }) {
    final result = create();
    if (messages != null) result.messages.addAll(messages);
    return result;
  }

  GetIntegrityMessagesResponse._();

  factory GetIntegrityMessagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetIntegrityMessagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetIntegrityMessagesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..pPM<$1.IntegrityMessage>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: $1.IntegrityMessage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIntegrityMessagesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIntegrityMessagesResponse copyWith(
          void Function(GetIntegrityMessagesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetIntegrityMessagesResponse))
          as GetIntegrityMessagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetIntegrityMessagesResponse create() =>
      GetIntegrityMessagesResponse._();
  @$core.override
  GetIntegrityMessagesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetIntegrityMessagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetIntegrityMessagesResponse>(create);
  static GetIntegrityMessagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.IntegrityMessage> get messages => $_getList(0);
}

class StreamIntegrityMessagesRequest extends $pb.GeneratedMessage {
  factory StreamIntegrityMessagesRequest() => create();

  StreamIntegrityMessagesRequest._();

  factory StreamIntegrityMessagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamIntegrityMessagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamIntegrityMessagesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamIntegrityMessagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamIntegrityMessagesRequest copyWith(
          void Function(StreamIntegrityMessagesRequest) updates) =>
      super.copyWith(
              (message) => updates(message as StreamIntegrityMessagesRequest))
          as StreamIntegrityMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamIntegrityMessagesRequest create() =>
      StreamIntegrityMessagesRequest._();
  @$core.override
  StreamIntegrityMessagesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamIntegrityMessagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamIntegrityMessagesRequest>(create);
  static StreamIntegrityMessagesRequest? _defaultInstance;
}

class StreamIntegrityMessagesResponse extends $pb.GeneratedMessage {
  factory StreamIntegrityMessagesResponse({
    $core.Iterable<$1.IntegrityMessage>? messages,
  }) {
    final result = create();
    if (messages != null) result.messages.addAll(messages);
    return result;
  }

  StreamIntegrityMessagesResponse._();

  factory StreamIntegrityMessagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamIntegrityMessagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamIntegrityMessagesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.api'),
      createEmptyInstance: create)
    ..pPM<$1.IntegrityMessage>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: $1.IntegrityMessage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamIntegrityMessagesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamIntegrityMessagesResponse copyWith(
          void Function(StreamIntegrityMessagesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as StreamIntegrityMessagesResponse))
          as StreamIntegrityMessagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamIntegrityMessagesResponse create() =>
      StreamIntegrityMessagesResponse._();
  @$core.override
  StreamIntegrityMessagesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamIntegrityMessagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamIntegrityMessagesResponse>(
          create);
  static StreamIntegrityMessagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.IntegrityMessage> get messages => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
