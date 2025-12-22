// This is a generated file - do not edit.
//
// Generated from db/db.proto.

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

@$core.Deprecated('Use seasonDescriptor instead')
const Season$json = {
  '1': 'Season',
  '2': [
    {'1': 'AGNOSTIC', '2': 0},
    {'1': 'SEASON_2025', '2': 10},
  ],
};

/// Descriptor for `Season`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List seasonDescriptor = $convert
    .base64Decode('CgZTZWFzb24SDAoIQUdOT1NUSUMQABIPCgtTRUFTT05fMjAyNRAK');

@$core.Deprecated('Use matchTypeDescriptor instead')
const MatchType$json = {
  '1': 'MatchType',
  '2': [
    {'1': 'RANKING', '2': 0},
    {'1': 'PRACTICE', '2': 1},
  ],
};

/// Descriptor for `MatchType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List matchTypeDescriptor = $convert
    .base64Decode('CglNYXRjaFR5cGUSCwoHUkFOS0lORxAAEgwKCFBSQUNUSUNFEAE=');

@$core.Deprecated('Use secretDescriptor instead')
const Secret$json = {
  '1': 'Secret',
  '2': [
    {'1': 'secret_bytes', '3': 1, '4': 1, '5': 12, '10': 'secretBytes'},
  ],
};

/// Descriptor for `Secret`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secretDescriptor = $convert.base64Decode(
    'CgZTZWNyZXQSIQoMc2VjcmV0X2J5dGVzGAEgASgMUgtzZWNyZXRCeXRlcw==');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {
      '1': 'roles',
      '3': 3,
      '4': 3,
      '5': 14,
      '6': '.tms.common.Role',
      '10': 'roles'
    },
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEhoKCHVzZXJuYW1lGAEgASgJUgh1c2VybmFtZRIaCghwYXNzd29yZBgCIAEoCVIIcG'
    'Fzc3dvcmQSJgoFcm9sZXMYAyADKA4yEC50bXMuY29tbW9uLlJvbGVSBXJvbGVz');

@$core.Deprecated('Use tournamentDescriptor instead')
const Tournament$json = {
  '1': 'Tournament',
  '2': [
    {'1': 'bootstrapped', '3': 1, '4': 1, '5': 8, '10': 'bootstrapped'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'backup_interval', '3': 3, '4': 1, '5': 13, '10': 'backupInterval'},
    {'1': 'retain_backups', '3': 4, '4': 1, '5': 13, '10': 'retainBackups'},
    {
      '1': 'end_game_timer_trigger',
      '3': 5,
      '4': 1,
      '5': 13,
      '10': 'endGameTimerTrigger'
    },
    {
      '1': 'game_timer_length',
      '3': 6,
      '4': 1,
      '5': 13,
      '10': 'gameTimerLength'
    },
    {
      '1': 'season',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.tms.db.Season',
      '10': 'season'
    },
    {'1': 'event_key', '3': 8, '4': 1, '5': 9, '10': 'eventKey'},
  ],
};

/// Descriptor for `Tournament`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tournamentDescriptor = $convert.base64Decode(
    'CgpUb3VybmFtZW50EiIKDGJvb3RzdHJhcHBlZBgBIAEoCFIMYm9vdHN0cmFwcGVkEhIKBG5hbW'
    'UYAiABKAlSBG5hbWUSJwoPYmFja3VwX2ludGVydmFsGAMgASgNUg5iYWNrdXBJbnRlcnZhbBIl'
    'Cg5yZXRhaW5fYmFja3VwcxgEIAEoDVINcmV0YWluQmFja3VwcxIzChZlbmRfZ2FtZV90aW1lcl'
    '90cmlnZ2VyGAUgASgNUhNlbmRHYW1lVGltZXJUcmlnZ2VyEioKEWdhbWVfdGltZXJfbGVuZ3Ro'
    'GAYgASgNUg9nYW1lVGltZXJMZW5ndGgSJgoGc2Vhc29uGAcgASgOMg4udG1zLmRiLlNlYXNvbl'
    'IGc2Vhc29uEhsKCWV2ZW50X2tleRgIIAEoCVIIZXZlbnRLZXk=');

@$core.Deprecated('Use teamDescriptor instead')
const Team$json = {
  '1': 'Team',
  '2': [
    {'1': 'team_number', '3': 1, '4': 1, '5': 9, '10': 'teamNumber'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'affiliation', '3': 3, '4': 1, '5': 9, '10': 'affiliation'},
  ],
};

/// Descriptor for `Team`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamDescriptor = $convert.base64Decode(
    'CgRUZWFtEh8KC3RlYW1fbnVtYmVyGAEgASgJUgp0ZWFtTnVtYmVyEhIKBG5hbWUYAiABKAlSBG'
    '5hbWUSIAoLYWZmaWxpYXRpb24YAyABKAlSC2FmZmlsaWF0aW9u');

@$core.Deprecated('Use tableAssignmentDescriptor instead')
const TableAssignment$json = {
  '1': 'TableAssignment',
  '2': [
    {'1': 'table_id', '3': 1, '4': 1, '5': 9, '10': 'tableId'},
    {'1': 'team_id', '3': 2, '4': 1, '5': 9, '10': 'teamId'},
    {'1': 'score_submitted', '3': 3, '4': 1, '5': 8, '10': 'scoreSubmitted'},
  ],
};

/// Descriptor for `TableAssignment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tableAssignmentDescriptor = $convert.base64Decode(
    'Cg9UYWJsZUFzc2lnbm1lbnQSGQoIdGFibGVfaWQYASABKAlSB3RhYmxlSWQSFwoHdGVhbV9pZB'
    'gCIAEoCVIGdGVhbUlkEicKD3Njb3JlX3N1Ym1pdHRlZBgDIAEoCFIOc2NvcmVTdWJtaXR0ZWQ=');

@$core.Deprecated('Use gameMatchDescriptor instead')
const GameMatch$json = {
  '1': 'GameMatch',
  '2': [
    {'1': 'match_number', '3': 1, '4': 1, '5': 9, '10': 'matchNumber'},
    {
      '1': 'start_time',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tms.common.TmsDateTime',
      '10': 'startTime'
    },
    {
      '1': 'end_time',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.tms.common.TmsDateTime',
      '10': 'endTime'
    },
    {
      '1': 'assignments',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.tms.db.TableAssignment',
      '10': 'assignments'
    },
    {'1': 'completed', '3': 5, '4': 1, '5': 8, '10': 'completed'},
    {
      '1': 'match_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.tms.db.MatchType',
      '10': 'matchType'
    },
  ],
};

/// Descriptor for `GameMatch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gameMatchDescriptor = $convert.base64Decode(
    'CglHYW1lTWF0Y2gSIQoMbWF0Y2hfbnVtYmVyGAEgASgJUgttYXRjaE51bWJlchI2CgpzdGFydF'
    '90aW1lGAIgASgLMhcudG1zLmNvbW1vbi5UbXNEYXRlVGltZVIJc3RhcnRUaW1lEjIKCGVuZF90'
    'aW1lGAMgASgLMhcudG1zLmNvbW1vbi5UbXNEYXRlVGltZVIHZW5kVGltZRI5Cgthc3NpZ25tZW'
    '50cxgEIAMoCzIXLnRtcy5kYi5UYWJsZUFzc2lnbm1lbnRSC2Fzc2lnbm1lbnRzEhwKCWNvbXBs'
    'ZXRlZBgFIAEoCFIJY29tcGxldGVkEjAKCm1hdGNoX3R5cGUYBiABKA4yES50bXMuZGIuTWF0Y2'
    'hUeXBlUgltYXRjaFR5cGU=');

@$core.Deprecated('Use podAssignmentDescriptor instead')
const PodAssignment$json = {
  '1': 'PodAssignment',
  '2': [
    {'1': 'pod_id', '3': 1, '4': 1, '5': 9, '10': 'podId'},
    {'1': 'team_id', '3': 2, '4': 1, '5': 9, '10': 'teamId'},
    {
      '1': 'core_values_submitted',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'coreValuesSubmitted'
    },
    {
      '1': 'innovation_submitted',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'innovationSubmitted'
    },
    {
      '1': 'robot_design_submitted',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'robotDesignSubmitted'
    },
  ],
};

/// Descriptor for `PodAssignment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List podAssignmentDescriptor = $convert.base64Decode(
    'Cg1Qb2RBc3NpZ25tZW50EhUKBnBvZF9pZBgBIAEoCVIFcG9kSWQSFwoHdGVhbV9pZBgCIAEoCV'
    'IGdGVhbUlkEjIKFWNvcmVfdmFsdWVzX3N1Ym1pdHRlZBgDIAEoCFITY29yZVZhbHVlc1N1Ym1p'
    'dHRlZBIxChRpbm5vdmF0aW9uX3N1Ym1pdHRlZBgEIAEoCFITaW5ub3ZhdGlvblN1Ym1pdHRlZB'
    'I0ChZyb2JvdF9kZXNpZ25fc3VibWl0dGVkGAUgASgIUhRyb2JvdERlc2lnblN1Ym1pdHRlZA==');

@$core.Deprecated('Use judgingSessionDescriptor instead')
const JudgingSession$json = {
  '1': 'JudgingSession',
  '2': [
    {'1': 'session_number', '3': 1, '4': 1, '5': 9, '10': 'sessionNumber'},
    {
      '1': 'start_time',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tms.common.TmsDateTime',
      '10': 'startTime'
    },
    {
      '1': 'end_time',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.tms.common.TmsDateTime',
      '10': 'endTime'
    },
    {
      '1': 'assignments',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.tms.db.PodAssignment',
      '10': 'assignments'
    },
    {'1': 'complete', '3': 5, '4': 1, '5': 8, '10': 'complete'},
  ],
};

/// Descriptor for `JudgingSession`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List judgingSessionDescriptor = $convert.base64Decode(
    'Cg5KdWRnaW5nU2Vzc2lvbhIlCg5zZXNzaW9uX251bWJlchgBIAEoCVINc2Vzc2lvbk51bWJlch'
    'I2CgpzdGFydF90aW1lGAIgASgLMhcudG1zLmNvbW1vbi5UbXNEYXRlVGltZVIJc3RhcnRUaW1l'
    'EjIKCGVuZF90aW1lGAMgASgLMhcudG1zLmNvbW1vbi5UbXNEYXRlVGltZVIHZW5kVGltZRI3Cg'
    'thc3NpZ25tZW50cxgEIAMoCzIVLnRtcy5kYi5Qb2RBc3NpZ25tZW50Ugthc3NpZ25tZW50cxIa'
    'Cghjb21wbGV0ZRgFIAEoCFIIY29tcGxldGU=');

@$core.Deprecated('Use tableNameDescriptor instead')
const TableName$json = {
  '1': 'TableName',
  '2': [
    {'1': 'table_name', '3': 1, '4': 1, '5': 9, '10': 'tableName'},
  ],
};

/// Descriptor for `TableName`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tableNameDescriptor = $convert
    .base64Decode('CglUYWJsZU5hbWUSHQoKdGFibGVfbmFtZRgBIAEoCVIJdGFibGVOYW1l');

@$core.Deprecated('Use podNameDescriptor instead')
const PodName$json = {
  '1': 'PodName',
  '2': [
    {'1': 'pod_name', '3': 2, '4': 1, '5': 9, '10': 'podName'},
  ],
};

/// Descriptor for `PodName`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List podNameDescriptor =
    $convert.base64Decode('CgdQb2ROYW1lEhkKCHBvZF9uYW1lGAIgASgJUgdwb2ROYW1l');
