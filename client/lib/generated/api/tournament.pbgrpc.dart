// This is a generated file - do not edit.
//
// Generated from api/tournament.proto.

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

import 'tournament.pb.dart' as $0;

export 'tournament.pb.dart';

@$pb.GrpcServiceName('tms.api.TournamentService')
class TournamentServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TournamentServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GetTournamentResponse> getTournament(
    $0.GetTournamentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTournament, request, options: options);
  }

  $grpc.ResponseFuture<$0.SetTournamentResponse> setTournament(
    $0.SetTournamentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setTournament, request, options: options);
  }

  $grpc.ResponseStream<$0.StreamTournamentResponse> streamTournament(
    $0.StreamTournamentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamTournament, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$getTournament =
      $grpc.ClientMethod<$0.GetTournamentRequest, $0.GetTournamentResponse>(
          '/tms.api.TournamentService/GetTournament',
          ($0.GetTournamentRequest value) => value.writeToBuffer(),
          $0.GetTournamentResponse.fromBuffer);
  static final _$setTournament =
      $grpc.ClientMethod<$0.SetTournamentRequest, $0.SetTournamentResponse>(
          '/tms.api.TournamentService/SetTournament',
          ($0.SetTournamentRequest value) => value.writeToBuffer(),
          $0.SetTournamentResponse.fromBuffer);
  static final _$streamTournament = $grpc.ClientMethod<
          $0.StreamTournamentRequest, $0.StreamTournamentResponse>(
      '/tms.api.TournamentService/StreamTournament',
      ($0.StreamTournamentRequest value) => value.writeToBuffer(),
      $0.StreamTournamentResponse.fromBuffer);
}

@$pb.GrpcServiceName('tms.api.TournamentService')
abstract class TournamentServiceBase extends $grpc.Service {
  $core.String get $name => 'tms.api.TournamentService';

  TournamentServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.GetTournamentRequest, $0.GetTournamentResponse>(
            'GetTournament',
            getTournament_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetTournamentRequest.fromBuffer(value),
            ($0.GetTournamentResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SetTournamentRequest, $0.SetTournamentResponse>(
            'SetTournament',
            setTournament_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SetTournamentRequest.fromBuffer(value),
            ($0.SetTournamentResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamTournamentRequest,
            $0.StreamTournamentResponse>(
        'StreamTournament',
        streamTournament_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamTournamentRequest.fromBuffer(value),
        ($0.StreamTournamentResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetTournamentResponse> getTournament_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetTournamentRequest> $request) async {
    return getTournament($call, await $request);
  }

  $async.Future<$0.GetTournamentResponse> getTournament(
      $grpc.ServiceCall call, $0.GetTournamentRequest request);

  $async.Future<$0.SetTournamentResponse> setTournament_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetTournamentRequest> $request) async {
    return setTournament($call, await $request);
  }

  $async.Future<$0.SetTournamentResponse> setTournament(
      $grpc.ServiceCall call, $0.SetTournamentRequest request);

  $async.Stream<$0.StreamTournamentResponse> streamTournament_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamTournamentRequest> $request) async* {
    yield* streamTournament($call, await $request);
  }

  $async.Stream<$0.StreamTournamentResponse> streamTournament(
      $grpc.ServiceCall call, $0.StreamTournamentRequest request);
}
