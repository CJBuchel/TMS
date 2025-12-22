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
