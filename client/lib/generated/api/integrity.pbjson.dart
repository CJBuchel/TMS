// This is a generated file - do not edit.
//
// Generated from api/integrity.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use getIntegrityMessagesRequestDescriptor instead')
const GetIntegrityMessagesRequest$json = {
  '1': 'GetIntegrityMessagesRequest',
};

/// Descriptor for `GetIntegrityMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getIntegrityMessagesRequestDescriptor =
    $convert.base64Decode('ChtHZXRJbnRlZ3JpdHlNZXNzYWdlc1JlcXVlc3Q=');

@$core.Deprecated('Use getIntegrityMessagesResponseDescriptor instead')
const GetIntegrityMessagesResponse$json = {
  '1': 'GetIntegrityMessagesResponse',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tms.common.IntegrityMessage',
      '10': 'messages'
    },
  ],
};

/// Descriptor for `GetIntegrityMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getIntegrityMessagesResponseDescriptor =
    $convert.base64Decode(
        'ChxHZXRJbnRlZ3JpdHlNZXNzYWdlc1Jlc3BvbnNlEjgKCG1lc3NhZ2VzGAEgAygLMhwudG1zLm'
        'NvbW1vbi5JbnRlZ3JpdHlNZXNzYWdlUghtZXNzYWdlcw==');

@$core.Deprecated('Use streamIntegrityMessagesRequestDescriptor instead')
const StreamIntegrityMessagesRequest$json = {
  '1': 'StreamIntegrityMessagesRequest',
};

/// Descriptor for `StreamIntegrityMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamIntegrityMessagesRequestDescriptor =
    $convert.base64Decode('Ch5TdHJlYW1JbnRlZ3JpdHlNZXNzYWdlc1JlcXVlc3Q=');

@$core.Deprecated('Use streamIntegrityMessagesResponseDescriptor instead')
const StreamIntegrityMessagesResponse$json = {
  '1': 'StreamIntegrityMessagesResponse',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tms.common.IntegrityMessage',
      '10': 'messages'
    },
  ],
};

/// Descriptor for `StreamIntegrityMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamIntegrityMessagesResponseDescriptor =
    $convert.base64Decode(
        'Ch9TdHJlYW1JbnRlZ3JpdHlNZXNzYWdlc1Jlc3BvbnNlEjgKCG1lc3NhZ2VzGAEgAygLMhwudG'
        '1zLmNvbW1vbi5JbnRlZ3JpdHlNZXNzYWdlUghtZXNzYWdlcw==');
