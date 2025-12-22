// This is a generated file - do not edit.
//
// Generated from api/api.proto.

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

import 'api.pb.dart' as $0;

export 'api.pb.dart';

@$pb.GrpcServiceName('tms.api.HealthService')
class HealthServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  HealthServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GetHealthResponse> getHealth(
    $0.GetHealthRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHealth, request, options: options);
  }

  $grpc.ResponseStream<$0.GetHealthResponse> streamHealth(
    $0.GetHealthRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamHealth, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$getHealth =
      $grpc.ClientMethod<$0.GetHealthRequest, $0.GetHealthResponse>(
          '/tms.api.HealthService/GetHealth',
          ($0.GetHealthRequest value) => value.writeToBuffer(),
          $0.GetHealthResponse.fromBuffer);
  static final _$streamHealth =
      $grpc.ClientMethod<$0.GetHealthRequest, $0.GetHealthResponse>(
          '/tms.api.HealthService/StreamHealth',
          ($0.GetHealthRequest value) => value.writeToBuffer(),
          $0.GetHealthResponse.fromBuffer);
}

@$pb.GrpcServiceName('tms.api.HealthService')
abstract class HealthServiceBase extends $grpc.Service {
  $core.String get $name => 'tms.api.HealthService';

  HealthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetHealthRequest, $0.GetHealthResponse>(
        'GetHealth',
        getHealth_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetHealthRequest.fromBuffer(value),
        ($0.GetHealthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetHealthRequest, $0.GetHealthResponse>(
        'StreamHealth',
        streamHealth_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.GetHealthRequest.fromBuffer(value),
        ($0.GetHealthResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetHealthResponse> getHealth_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetHealthRequest> $request) async {
    return getHealth($call, await $request);
  }

  $async.Future<$0.GetHealthResponse> getHealth(
      $grpc.ServiceCall call, $0.GetHealthRequest request);

  $async.Stream<$0.GetHealthResponse> streamHealth_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetHealthRequest> $request) async* {
    yield* streamHealth($call, await $request);
  }

  $async.Stream<$0.GetHealthResponse> streamHealth(
      $grpc.ServiceCall call, $0.GetHealthRequest request);
}
