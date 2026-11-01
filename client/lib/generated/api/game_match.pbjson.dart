// This is a generated file - do not edit.
//
// Generated from api/game_match.proto.

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

@$core.Deprecated('Use gameMatchResponseDescriptor instead')
const GameMatchResponse$json = {
  '1': 'GameMatchResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'game_match',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tms.db.GameMatch',
      '10': 'gameMatch'
    },
  ],
};

/// Descriptor for `GameMatchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gameMatchResponseDescriptor = $convert.base64Decode(
    'ChFHYW1lTWF0Y2hSZXNwb25zZRIOCgJpZBgBIAEoCVICaWQSMAoKZ2FtZV9tYXRjaBgCIAEoCz'
    'IRLnRtcy5kYi5HYW1lTWF0Y2hSCWdhbWVNYXRjaA==');

@$core.Deprecated('Use streamMatchesRequestDescriptor instead')
const StreamMatchesRequest$json = {
  '1': 'StreamMatchesRequest',
};

/// Descriptor for `StreamMatchesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamMatchesRequestDescriptor =
    $convert.base64Decode('ChRTdHJlYW1NYXRjaGVzUmVxdWVzdA==');

@$core.Deprecated('Use streamMatchesResponseDescriptor instead')
const StreamMatchesResponse$json = {
  '1': 'StreamMatchesResponse',
  '2': [
    {
      '1': 'game_matches',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tms.api.GameMatchResponse',
      '10': 'gameMatches'
    },
  ],
};

/// Descriptor for `StreamMatchesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamMatchesResponseDescriptor = $convert.base64Decode(
    'ChVTdHJlYW1NYXRjaGVzUmVzcG9uc2USPQoMZ2FtZV9tYXRjaGVzGAEgAygLMhoudG1zLmFwaS'
    '5HYW1lTWF0Y2hSZXNwb25zZVILZ2FtZU1hdGNoZXM=');

@$core.Deprecated('Use submitSignatureRequestDescriptor instead')
const SubmitSignatureRequest$json = {
  '1': 'SubmitSignatureRequest',
  '2': [
    {'1': 'match_id', '3': 1, '4': 1, '5': 9, '10': 'matchId'},
    {'1': 'table_id', '3': 2, '4': 1, '5': 9, '10': 'tableId'},
    {'1': 'signature_png', '3': 3, '4': 1, '5': 12, '10': 'signaturePng'},
  ],
};

/// Descriptor for `SubmitSignatureRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitSignatureRequestDescriptor = $convert.base64Decode(
    'ChZTdWJtaXRTaWduYXR1cmVSZXF1ZXN0EhkKCG1hdGNoX2lkGAEgASgJUgdtYXRjaElkEhkKCH'
    'RhYmxlX2lkGAIgASgJUgd0YWJsZUlkEiMKDXNpZ25hdHVyZV9wbmcYAyABKAxSDHNpZ25hdHVy'
    'ZVBuZw==');

@$core.Deprecated('Use submitSignatureResponseDescriptor instead')
const SubmitSignatureResponse$json = {
  '1': 'SubmitSignatureResponse',
};

/// Descriptor for `SubmitSignatureResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitSignatureResponseDescriptor =
    $convert.base64Decode('ChdTdWJtaXRTaWduYXR1cmVSZXNwb25zZQ==');

@$core.Deprecated('Use getSignatureRequestDescriptor instead')
const GetSignatureRequest$json = {
  '1': 'GetSignatureRequest',
  '2': [
    {'1': 'match_id', '3': 1, '4': 1, '5': 9, '10': 'matchId'},
    {'1': 'table_id', '3': 2, '4': 1, '5': 9, '10': 'tableId'},
  ],
};

/// Descriptor for `GetSignatureRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSignatureRequestDescriptor = $convert.base64Decode(
    'ChNHZXRTaWduYXR1cmVSZXF1ZXN0EhkKCG1hdGNoX2lkGAEgASgJUgdtYXRjaElkEhkKCHRhYm'
    'xlX2lkGAIgASgJUgd0YWJsZUlk');

@$core.Deprecated('Use getSignatureResponseDescriptor instead')
const GetSignatureResponse$json = {
  '1': 'GetSignatureResponse',
  '2': [
    {
      '1': 'signature',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tms.db.TeamSignature',
      '9': 0,
      '10': 'signature',
      '17': true
    },
  ],
  '8': [
    {'1': '_signature'},
  ],
};

/// Descriptor for `GetSignatureResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSignatureResponseDescriptor = $convert.base64Decode(
    'ChRHZXRTaWduYXR1cmVSZXNwb25zZRI4CglzaWduYXR1cmUYASABKAsyFS50bXMuZGIuVGVhbV'
    'NpZ25hdHVyZUgAUglzaWduYXR1cmWIAQFCDAoKX3NpZ25hdHVyZQ==');
