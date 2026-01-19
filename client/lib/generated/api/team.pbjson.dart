// This is a generated file - do not edit.
//
// Generated from api/team.proto.

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

@$core.Deprecated('Use teamResponseDescriptor instead')
const TeamResponse$json = {
  '1': 'TeamResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'team', '3': 2, '4': 1, '5': 11, '6': '.tms.db.Team', '10': 'team'},
  ],
};

/// Descriptor for `TeamResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamResponseDescriptor = $convert.base64Decode(
    'CgxUZWFtUmVzcG9uc2USDgoCaWQYASABKAlSAmlkEiAKBHRlYW0YAiABKAsyDC50bXMuZGIuVG'
    'VhbVIEdGVhbQ==');

@$core.Deprecated('Use streamTeamsRequestDescriptor instead')
const StreamTeamsRequest$json = {
  '1': 'StreamTeamsRequest',
};

/// Descriptor for `StreamTeamsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamTeamsRequestDescriptor =
    $convert.base64Decode('ChJTdHJlYW1UZWFtc1JlcXVlc3Q=');

@$core.Deprecated('Use streamTeamsResponseDescriptor instead')
const StreamTeamsResponse$json = {
  '1': 'StreamTeamsResponse',
  '2': [
    {
      '1': 'teams',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tms.api.TeamResponse',
      '10': 'teams'
    },
  ],
};

/// Descriptor for `StreamTeamsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamTeamsResponseDescriptor = $convert.base64Decode(
    'ChNTdHJlYW1UZWFtc1Jlc3BvbnNlEisKBXRlYW1zGAEgAygLMhUudG1zLmFwaS5UZWFtUmVzcG'
    '9uc2VSBXRlYW1z');
