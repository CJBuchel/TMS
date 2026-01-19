// This is a generated file - do not edit.
//
// Generated from api/table_name.proto.

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

@$core.Deprecated('Use tableNameResponseDescriptor instead')
const TableNameResponse$json = {
  '1': 'TableNameResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'table_name',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tms.db.TableName',
      '10': 'tableName'
    },
  ],
};

/// Descriptor for `TableNameResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tableNameResponseDescriptor = $convert.base64Decode(
    'ChFUYWJsZU5hbWVSZXNwb25zZRIOCgJpZBgBIAEoCVICaWQSMAoKdGFibGVfbmFtZRgCIAEoCz'
    'IRLnRtcy5kYi5UYWJsZU5hbWVSCXRhYmxlTmFtZQ==');

@$core.Deprecated('Use streamTableNamesRequestDescriptor instead')
const StreamTableNamesRequest$json = {
  '1': 'StreamTableNamesRequest',
};

/// Descriptor for `StreamTableNamesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamTableNamesRequestDescriptor =
    $convert.base64Decode('ChdTdHJlYW1UYWJsZU5hbWVzUmVxdWVzdA==');

@$core.Deprecated('Use streamTableNamesResponseDescriptor instead')
const StreamTableNamesResponse$json = {
  '1': 'StreamTableNamesResponse',
  '2': [
    {
      '1': 'table_names',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tms.api.TableNameResponse',
      '10': 'tableNames'
    },
  ],
};

/// Descriptor for `StreamTableNamesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamTableNamesResponseDescriptor =
    $convert.base64Decode(
        'ChhTdHJlYW1UYWJsZU5hbWVzUmVzcG9uc2USOwoLdGFibGVfbmFtZXMYASADKAsyGi50bXMuYX'
        'BpLlRhYmxlTmFtZVJlc3BvbnNlUgp0YWJsZU5hbWVz');
