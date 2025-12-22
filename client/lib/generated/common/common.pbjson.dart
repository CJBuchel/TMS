// This is a generated file - do not edit.
//
// Generated from common/common.proto.

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

@$core.Deprecated('Use roleDescriptor instead')
const Role$json = {
  '1': 'Role',
  '2': [
    {'1': 'ADMIN', '2': 0},
    {'1': 'REFEREE', '2': 1},
    {'1': 'HEAD_REFEREE', '2': 2},
    {'1': 'JUDGE', '2': 3},
    {'1': 'JUDGE_ADVISOR', '2': 4},
    {'1': 'SCORE_KEEPER', '2': 5},
    {'1': 'EMCEE', '2': 6},
    {'1': 'AV', '2': 7},
  ],
};

/// Descriptor for `Role`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List roleDescriptor = $convert.base64Decode(
    'CgRSb2xlEgkKBUFETUlOEAASCwoHUkVGRVJFRRABEhAKDEhFQURfUkVGRVJFRRACEgkKBUpVRE'
    'dFEAMSEQoNSlVER0VfQURWSVNPUhAEEhAKDFNDT1JFX0tFRVBFUhAFEgkKBUVNQ0VFEAYSBgoC'
    'QVYQBw==');

@$core.Deprecated('Use timestampDescriptor instead')
const Timestamp$json = {
  '1': 'Timestamp',
  '2': [
    {'1': 'seconds', '3': 1, '4': 1, '5': 3, '10': 'seconds'},
    {'1': 'nanos', '3': 2, '4': 1, '5': 5, '10': 'nanos'},
  ],
};

/// Descriptor for `Timestamp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timestampDescriptor = $convert.base64Decode(
    'CglUaW1lc3RhbXASGAoHc2Vjb25kcxgBIAEoA1IHc2Vjb25kcxIUCgVuYW5vcxgCIAEoBVIFbm'
    'Fub3M=');

@$core.Deprecated('Use tmsDateDescriptor instead')
const TmsDate$json = {
  '1': 'TmsDate',
  '2': [
    {'1': 'year', '3': 1, '4': 1, '5': 5, '10': 'year'},
    {'1': 'month', '3': 2, '4': 1, '5': 5, '10': 'month'},
    {'1': 'day', '3': 3, '4': 1, '5': 5, '10': 'day'},
  ],
};

/// Descriptor for `TmsDate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tmsDateDescriptor = $convert.base64Decode(
    'CgdUbXNEYXRlEhIKBHllYXIYASABKAVSBHllYXISFAoFbW9udGgYAiABKAVSBW1vbnRoEhAKA2'
    'RheRgDIAEoBVIDZGF5');

@$core.Deprecated('Use tmsTimeDescriptor instead')
const TmsTime$json = {
  '1': 'TmsTime',
  '2': [
    {'1': 'hour', '3': 1, '4': 1, '5': 13, '10': 'hour'},
    {'1': 'minute', '3': 2, '4': 1, '5': 13, '10': 'minute'},
    {'1': 'second', '3': 3, '4': 1, '5': 13, '10': 'second'},
  ],
};

/// Descriptor for `TmsTime`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tmsTimeDescriptor = $convert.base64Decode(
    'CgdUbXNUaW1lEhIKBGhvdXIYASABKA1SBGhvdXISFgoGbWludXRlGAIgASgNUgZtaW51dGUSFg'
    'oGc2Vjb25kGAMgASgNUgZzZWNvbmQ=');

@$core.Deprecated('Use tmsDateTimeDescriptor instead')
const TmsDateTime$json = {
  '1': 'TmsDateTime',
  '2': [
    {
      '1': 'date',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tms.common.TmsDate',
      '9': 0,
      '10': 'date',
      '17': true
    },
    {
      '1': 'time',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tms.common.TmsTime',
      '9': 1,
      '10': 'time',
      '17': true
    },
  ],
  '8': [
    {'1': '_date'},
    {'1': '_time'},
  ],
};

/// Descriptor for `TmsDateTime`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tmsDateTimeDescriptor = $convert.base64Decode(
    'CgtUbXNEYXRlVGltZRIsCgRkYXRlGAEgASgLMhMudG1zLmNvbW1vbi5UbXNEYXRlSABSBGRhdG'
    'WIAQESLAoEdGltZRgCIAEoCzITLnRtcy5jb21tb24uVG1zVGltZUgBUgR0aW1liAEBQgcKBV9k'
    'YXRlQgcKBV90aW1l');
