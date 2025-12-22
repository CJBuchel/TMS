// This is a generated file - do not edit.
//
// Generated from api/schedule.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'schedule.pb.dart' as $0;

export 'schedule.pb.dart';

@$pb.GrpcServiceName('tms.api.ScheduleService')
class ScheduleServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ScheduleServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.UploadScheduleCsvResponse> uploadScheduleCsv(
    $0.UploadScheduleCsvRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$uploadScheduleCsv, request, options: options);
  }

  // method descriptors

  static final _$uploadScheduleCsv = $grpc.ClientMethod<
          $0.UploadScheduleCsvRequest, $0.UploadScheduleCsvResponse>(
      '/tms.api.ScheduleService/UploadScheduleCsv',
      ($0.UploadScheduleCsvRequest value) => value.writeToBuffer(),
      $0.UploadScheduleCsvResponse.fromBuffer);
}

@$pb.GrpcServiceName('tms.api.ScheduleService')
abstract class ScheduleServiceBase extends $grpc.Service {
  $core.String get $name => 'tms.api.ScheduleService';

  ScheduleServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.UploadScheduleCsvRequest,
            $0.UploadScheduleCsvResponse>(
        'UploadScheduleCsv',
        uploadScheduleCsv_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UploadScheduleCsvRequest.fromBuffer(value),
        ($0.UploadScheduleCsvResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.UploadScheduleCsvResponse> uploadScheduleCsv_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UploadScheduleCsvRequest> $request) async {
    return uploadScheduleCsv($call, await $request);
  }

  $async.Future<$0.UploadScheduleCsvResponse> uploadScheduleCsv(
      $grpc.ServiceCall call, $0.UploadScheduleCsvRequest request);
}
