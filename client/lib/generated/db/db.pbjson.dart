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
    {'1': 'season', '3': 7, '4': 1, '5': 9, '9': 0, '10': 'season', '17': true},
  ],
  '8': [
    {'1': '_season'},
  ],
};

/// Descriptor for `Tournament`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tournamentDescriptor = $convert.base64Decode(
    'CgpUb3VybmFtZW50EiIKDGJvb3RzdHJhcHBlZBgBIAEoCFIMYm9vdHN0cmFwcGVkEhIKBG5hbW'
    'UYAiABKAlSBG5hbWUSJwoPYmFja3VwX2ludGVydmFsGAMgASgNUg5iYWNrdXBJbnRlcnZhbBIl'
    'Cg5yZXRhaW5fYmFja3VwcxgEIAEoDVINcmV0YWluQmFja3VwcxIzChZlbmRfZ2FtZV90aW1lcl'
    '90cmlnZ2VyGAUgASgNUhNlbmRHYW1lVGltZXJUcmlnZ2VyEioKEWdhbWVfdGltZXJfbGVuZ3Ro'
    'GAYgASgNUg9nYW1lVGltZXJMZW5ndGgSGwoGc2Vhc29uGAcgASgJSABSBnNlYXNvbogBAUIJCg'
    'dfc2Vhc29u');
