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
