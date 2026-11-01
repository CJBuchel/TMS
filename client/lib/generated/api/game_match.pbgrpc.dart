// This is a generated file - do not edit.
//
// Generated from api/game_match.proto.

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

import 'game_match.pb.dart' as $0;

export 'game_match.pb.dart';

@$pb.GrpcServiceName('tms.api.GameMatchService')
class GameMatchServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  GameMatchServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$0.StreamMatchesResponse> streamMatches(
    $0.StreamMatchesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamMatches, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.SubmitSignatureResponse> submitSignature(
    $0.SubmitSignatureRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$submitSignature, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetSignatureResponse> getSignature(
    $0.GetSignatureRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSignature, request, options: options);
  }

  // method descriptors

  static final _$streamMatches =
      $grpc.ClientMethod<$0.StreamMatchesRequest, $0.StreamMatchesResponse>(
          '/tms.api.GameMatchService/StreamMatches',
          ($0.StreamMatchesRequest value) => value.writeToBuffer(),
          $0.StreamMatchesResponse.fromBuffer);
  static final _$submitSignature =
      $grpc.ClientMethod<$0.SubmitSignatureRequest, $0.SubmitSignatureResponse>(
          '/tms.api.GameMatchService/SubmitSignature',
          ($0.SubmitSignatureRequest value) => value.writeToBuffer(),
          $0.SubmitSignatureResponse.fromBuffer);
  static final _$getSignature =
      $grpc.ClientMethod<$0.GetSignatureRequest, $0.GetSignatureResponse>(
          '/tms.api.GameMatchService/GetSignature',
          ($0.GetSignatureRequest value) => value.writeToBuffer(),
          $0.GetSignatureResponse.fromBuffer);
}

@$pb.GrpcServiceName('tms.api.GameMatchService')
abstract class GameMatchServiceBase extends $grpc.Service {
  $core.String get $name => 'tms.api.GameMatchService';

  GameMatchServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.StreamMatchesRequest, $0.StreamMatchesResponse>(
            'StreamMatches',
            streamMatches_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.StreamMatchesRequest.fromBuffer(value),
            ($0.StreamMatchesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SubmitSignatureRequest,
            $0.SubmitSignatureResponse>(
        'SubmitSignature',
        submitSignature_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SubmitSignatureRequest.fromBuffer(value),
        ($0.SubmitSignatureResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetSignatureRequest, $0.GetSignatureResponse>(
            'GetSignature',
            getSignature_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetSignatureRequest.fromBuffer(value),
            ($0.GetSignatureResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.StreamMatchesResponse> streamMatches_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamMatchesRequest> $request) async* {
    yield* streamMatches($call, await $request);
  }

  $async.Stream<$0.StreamMatchesResponse> streamMatches(
      $grpc.ServiceCall call, $0.StreamMatchesRequest request);

  $async.Future<$0.SubmitSignatureResponse> submitSignature_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SubmitSignatureRequest> $request) async {
    return submitSignature($call, await $request);
  }

  $async.Future<$0.SubmitSignatureResponse> submitSignature(
      $grpc.ServiceCall call, $0.SubmitSignatureRequest request);

  $async.Future<$0.GetSignatureResponse> getSignature_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetSignatureRequest> $request) async {
    return getSignature($call, await $request);
  }

  $async.Future<$0.GetSignatureResponse> getSignature(
      $grpc.ServiceCall call, $0.GetSignatureRequest request);
}
