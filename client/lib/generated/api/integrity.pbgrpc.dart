// This is a generated file - do not edit.
//
// Generated from api/integrity.proto.

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

import 'integrity.pb.dart' as $0;

export 'integrity.pb.dart';

@$pb.GrpcServiceName('tms.api.IntegrityService')
class IntegrityServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  IntegrityServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GetIntegrityMessagesResponse> getIntegrityMessages(
    $0.GetIntegrityMessagesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getIntegrityMessages, request, options: options);
  }

  $grpc.ResponseStream<$0.StreamIntegrityMessagesResponse>
      streamIntegrityMessages(
    $0.StreamIntegrityMessagesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamIntegrityMessages, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$getIntegrityMessages = $grpc.ClientMethod<
          $0.GetIntegrityMessagesRequest, $0.GetIntegrityMessagesResponse>(
      '/tms.api.IntegrityService/GetIntegrityMessages',
      ($0.GetIntegrityMessagesRequest value) => value.writeToBuffer(),
      $0.GetIntegrityMessagesResponse.fromBuffer);
  static final _$streamIntegrityMessages = $grpc.ClientMethod<
          $0.StreamIntegrityMessagesRequest,
          $0.StreamIntegrityMessagesResponse>(
      '/tms.api.IntegrityService/StreamIntegrityMessages',
      ($0.StreamIntegrityMessagesRequest value) => value.writeToBuffer(),
      $0.StreamIntegrityMessagesResponse.fromBuffer);
}

@$pb.GrpcServiceName('tms.api.IntegrityService')
abstract class IntegrityServiceBase extends $grpc.Service {
  $core.String get $name => 'tms.api.IntegrityService';

  IntegrityServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetIntegrityMessagesRequest,
            $0.GetIntegrityMessagesResponse>(
        'GetIntegrityMessages',
        getIntegrityMessages_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetIntegrityMessagesRequest.fromBuffer(value),
        ($0.GetIntegrityMessagesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamIntegrityMessagesRequest,
            $0.StreamIntegrityMessagesResponse>(
        'StreamIntegrityMessages',
        streamIntegrityMessages_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamIntegrityMessagesRequest.fromBuffer(value),
        ($0.StreamIntegrityMessagesResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetIntegrityMessagesResponse> getIntegrityMessages_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetIntegrityMessagesRequest> $request) async {
    return getIntegrityMessages($call, await $request);
  }

  $async.Future<$0.GetIntegrityMessagesResponse> getIntegrityMessages(
      $grpc.ServiceCall call, $0.GetIntegrityMessagesRequest request);

  $async.Stream<$0.StreamIntegrityMessagesResponse> streamIntegrityMessages_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamIntegrityMessagesRequest> $request) async* {
    yield* streamIntegrityMessages($call, await $request);
  }

  $async.Stream<$0.StreamIntegrityMessagesResponse> streamIntegrityMessages(
      $grpc.ServiceCall call, $0.StreamIntegrityMessagesRequest request);
}
