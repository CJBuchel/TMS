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

@$core.Deprecated('Use integrityCodeDescriptor instead')
const IntegrityCode$json = {
  '1': 'IntegrityCode',
  '2': [
    {'1': 'E000', '2': 0},
    {'1': 'E001', '2': 1},
    {'1': 'E002', '2': 2},
    {'1': 'E003', '2': 3},
    {'1': 'E004', '2': 4},
    {'1': 'E005', '2': 5},
    {'1': 'E006', '2': 6},
    {'1': 'E007', '2': 7},
    {'1': 'E008', '2': 8},
    {'1': 'E009', '2': 9},
    {'1': 'E010', '2': 10},
    {'1': 'E011', '2': 11},
    {'1': 'E012', '2': 12},
    {'1': 'E013', '2': 13},
    {'1': 'W000', '2': 1000},
    {'1': 'W001', '2': 1001},
    {'1': 'W002', '2': 1002},
    {'1': 'W003', '2': 1003},
    {'1': 'W004', '2': 1004},
    {'1': 'W005', '2': 1005},
    {'1': 'W006', '2': 1006},
    {'1': 'W007', '2': 1007},
    {'1': 'W008', '2': 1008},
    {'1': 'W009', '2': 1009},
    {'1': 'W010', '2': 1010},
    {'1': 'W011', '2': 1011},
    {'1': 'W012', '2': 1012},
    {'1': 'W013', '2': 1013},
    {'1': 'W014', '2': 1014},
    {'1': 'W015', '2': 1015},
    {'1': 'W016', '2': 1016},
    {'1': 'W017', '2': 1017},
    {'1': 'W018', '2': 1018},
  ],
};

/// Descriptor for `IntegrityCode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List integrityCodeDescriptor = $convert.base64Decode(
    'Cg1JbnRlZ3JpdHlDb2RlEggKBEUwMDAQABIICgRFMDAxEAESCAoERTAwMhACEggKBEUwMDMQAx'
    'IICgRFMDA0EAQSCAoERTAwNRAFEggKBEUwMDYQBhIICgRFMDA3EAcSCAoERTAwOBAIEggKBEUw'
    'MDkQCRIICgRFMDEwEAoSCAoERTAxMRALEggKBEUwMTIQDBIICgRFMDEzEA0SCQoEVzAwMBDoBx'
    'IJCgRXMDAxEOkHEgkKBFcwMDIQ6gcSCQoEVzAwMxDrBxIJCgRXMDA0EOwHEgkKBFcwMDUQ7QcS'
    'CQoEVzAwNhDuBxIJCgRXMDA3EO8HEgkKBFcwMDgQ8AcSCQoEVzAwORDxBxIJCgRXMDEwEPIHEg'
    'kKBFcwMTEQ8wcSCQoEVzAxMhD0BxIJCgRXMDEzEPUHEgkKBFcwMTQQ9gcSCQoEVzAxNRD3BxIJ'
    'CgRXMDE2EPgHEgkKBFcwMTcQ+QcSCQoEVzAxOBD6Bw==');

@$core.Deprecated('Use integritySeverityDescriptor instead')
const IntegritySeverity$json = {
  '1': 'IntegritySeverity',
  '2': [
    {'1': 'UNSPECIFIED', '2': 0},
    {'1': 'ERROR', '2': 1},
    {'1': 'WARNING', '2': 2},
  ],
};

/// Descriptor for `IntegritySeverity`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List integritySeverityDescriptor = $convert.base64Decode(
    'ChFJbnRlZ3JpdHlTZXZlcml0eRIPCgtVTlNQRUNJRklFRBAAEgkKBUVSUk9SEAESCwoHV0FSTk'
    'lORxAC');

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

@$core.Deprecated('Use integrityContextDescriptor instead')
const IntegrityContext$json = {
  '1': 'IntegrityContext',
  '2': [
    {'1': 'context_keys', '3': 1, '4': 3, '5': 9, '10': 'contextKeys'},
    {
      '1': 'team_number',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'teamNumber',
      '17': true
    },
    {
      '1': 'match_number',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'matchNumber',
      '17': true
    },
    {
      '1': 'session_number',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'sessionNumber',
      '17': true
    },
    {
      '1': 'table_name',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'tableName',
      '17': true
    },
    {
      '1': 'pod_name',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'podName',
      '17': true
    },
  ],
  '8': [
    {'1': '_team_number'},
    {'1': '_match_number'},
    {'1': '_session_number'},
    {'1': '_table_name'},
    {'1': '_pod_name'},
  ],
};

/// Descriptor for `IntegrityContext`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List integrityContextDescriptor = $convert.base64Decode(
    'ChBJbnRlZ3JpdHlDb250ZXh0EiEKDGNvbnRleHRfa2V5cxgBIAMoCVILY29udGV4dEtleXMSJA'
    'oLdGVhbV9udW1iZXIYAiABKAlIAFIKdGVhbU51bWJlcogBARImCgxtYXRjaF9udW1iZXIYAyAB'
    'KAlIAVILbWF0Y2hOdW1iZXKIAQESKgoOc2Vzc2lvbl9udW1iZXIYBCABKAlIAlINc2Vzc2lvbk'
    '51bWJlcogBARIiCgp0YWJsZV9uYW1lGAUgASgJSANSCXRhYmxlTmFtZYgBARIeCghwb2RfbmFt'
    'ZRgGIAEoCUgEUgdwb2ROYW1liAEBQg4KDF90ZWFtX251bWJlckIPCg1fbWF0Y2hfbnVtYmVyQh'
    'EKD19zZXNzaW9uX251bWJlckINCgtfdGFibGVfbmFtZUILCglfcG9kX25hbWU=');

@$core.Deprecated('Use integrityMessageDescriptor instead')
const IntegrityMessage$json = {
  '1': 'IntegrityMessage',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.tms.common.IntegrityCode',
      '10': 'code'
    },
    {
      '1': 'severity',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.tms.common.IntegritySeverity',
      '10': 'severity'
    },
    {
      '1': 'context',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.tms.common.IntegrityContext',
      '10': 'context'
    },
    {
      '1': 'formatted_message',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'formattedMessage'
    },
  ],
};

/// Descriptor for `IntegrityMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List integrityMessageDescriptor = $convert.base64Decode(
    'ChBJbnRlZ3JpdHlNZXNzYWdlEi0KBGNvZGUYASABKA4yGS50bXMuY29tbW9uLkludGVncml0eU'
    'NvZGVSBGNvZGUSOQoIc2V2ZXJpdHkYAiABKA4yHS50bXMuY29tbW9uLkludGVncml0eVNldmVy'
    'aXR5UghzZXZlcml0eRI2Cgdjb250ZXh0GAMgASgLMhwudG1zLmNvbW1vbi5JbnRlZ3JpdHlDb2'
    '50ZXh0Ugdjb250ZXh0EisKEWZvcm1hdHRlZF9tZXNzYWdlGAQgASgJUhBmb3JtYXR0ZWRNZXNz'
    'YWdl');
