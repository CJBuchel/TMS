// This is a generated file - do not edit.
//
// Generated from api/tournament.proto.

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

@$core.Deprecated('Use getTournamentRequestDescriptor instead')
const GetTournamentRequest$json = {
  '1': 'GetTournamentRequest',
};

/// Descriptor for `GetTournamentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTournamentRequestDescriptor =
    $convert.base64Decode('ChRHZXRUb3VybmFtZW50UmVxdWVzdA==');

@$core.Deprecated('Use getTournamentResponseDescriptor instead')
const GetTournamentResponse$json = {
  '1': 'GetTournamentResponse',
  '2': [
    {
      '1': 'tournament',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tms.db.Tournament',
      '10': 'tournament'
    },
  ],
};

/// Descriptor for `GetTournamentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTournamentResponseDescriptor = $convert.base64Decode(
    'ChVHZXRUb3VybmFtZW50UmVzcG9uc2USMgoKdG91cm5hbWVudBgBIAEoCzISLnRtcy5kYi5Ub3'
    'VybmFtZW50Ugp0b3VybmFtZW50');

@$core.Deprecated('Use setTournamentRequestDescriptor instead')
const SetTournamentRequest$json = {
  '1': 'SetTournamentRequest',
  '2': [
    {
      '1': 'tournament',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tms.db.Tournament',
      '10': 'tournament'
    },
  ],
};

/// Descriptor for `SetTournamentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setTournamentRequestDescriptor = $convert.base64Decode(
    'ChRTZXRUb3VybmFtZW50UmVxdWVzdBIyCgp0b3VybmFtZW50GAEgASgLMhIudG1zLmRiLlRvdX'
    'JuYW1lbnRSCnRvdXJuYW1lbnQ=');

@$core.Deprecated('Use setTournamentResponseDescriptor instead')
const SetTournamentResponse$json = {
  '1': 'SetTournamentResponse',
};

/// Descriptor for `SetTournamentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setTournamentResponseDescriptor =
    $convert.base64Decode('ChVTZXRUb3VybmFtZW50UmVzcG9uc2U=');

@$core.Deprecated('Use streamTournamentRequestDescriptor instead')
const StreamTournamentRequest$json = {
  '1': 'StreamTournamentRequest',
};

/// Descriptor for `StreamTournamentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamTournamentRequestDescriptor =
    $convert.base64Decode('ChdTdHJlYW1Ub3VybmFtZW50UmVxdWVzdA==');

@$core.Deprecated('Use streamTournamentResponseDescriptor instead')
const StreamTournamentResponse$json = {
  '1': 'StreamTournamentResponse',
  '2': [
    {
      '1': 'tournament',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tms.db.Tournament',
      '10': 'tournament'
    },
  ],
};

/// Descriptor for `StreamTournamentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamTournamentResponseDescriptor =
    $convert.base64Decode(
        'ChhTdHJlYW1Ub3VybmFtZW50UmVzcG9uc2USMgoKdG91cm5hbWVudBgBIAEoCzISLnRtcy5kYi'
        '5Ub3VybmFtZW50Ugp0b3VybmFtZW50');
