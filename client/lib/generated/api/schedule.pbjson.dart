// This is a generated file - do not edit.
//
// Generated from api/schedule.proto.

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

@$core.Deprecated('Use uploadScheduleCsvRequestDescriptor instead')
const UploadScheduleCsvRequest$json = {
  '1': 'UploadScheduleCsvRequest',
  '2': [
    {'1': 'csv_data', '3': 1, '4': 1, '5': 12, '10': 'csvData'},
  ],
};

/// Descriptor for `UploadScheduleCsvRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadScheduleCsvRequestDescriptor =
    $convert.base64Decode(
        'ChhVcGxvYWRTY2hlZHVsZUNzdlJlcXVlc3QSGQoIY3N2X2RhdGEYASABKAxSB2NzdkRhdGE=');

@$core.Deprecated('Use uploadScheduleCsvResponseDescriptor instead')
const UploadScheduleCsvResponse$json = {
  '1': 'UploadScheduleCsvResponse',
};

/// Descriptor for `UploadScheduleCsvResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadScheduleCsvResponseDescriptor =
    $convert.base64Decode('ChlVcGxvYWRTY2hlZHVsZUNzdlJlc3BvbnNl');
