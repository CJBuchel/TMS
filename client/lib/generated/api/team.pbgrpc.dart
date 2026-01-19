// This is a generated file - do not edit.
//
// Generated from api/team.proto.

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

import 'team.pb.dart' as $0;

export 'team.pb.dart';

@$pb.GrpcServiceName('tms.api.TeamService')
class TeamServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TeamServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$0.StreamTeamsResponse> streamTeams(
    $0.StreamTeamsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamTeams, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$streamTeams =
      $grpc.ClientMethod<$0.StreamTeamsRequest, $0.StreamTeamsResponse>(
          '/tms.api.TeamService/StreamTeams',
          ($0.StreamTeamsRequest value) => value.writeToBuffer(),
          $0.StreamTeamsResponse.fromBuffer);
}

@$pb.GrpcServiceName('tms.api.TeamService')
abstract class TeamServiceBase extends $grpc.Service {
  $core.String get $name => 'tms.api.TeamService';

  TeamServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.StreamTeamsRequest, $0.StreamTeamsResponse>(
            'StreamTeams',
            streamTeams_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.StreamTeamsRequest.fromBuffer(value),
            ($0.StreamTeamsResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.StreamTeamsResponse> streamTeams_Pre($grpc.ServiceCall $call,
      $async.Future<$0.StreamTeamsRequest> $request) async* {
    yield* streamTeams($call, await $request);
  }

  $async.Stream<$0.StreamTeamsResponse> streamTeams(
      $grpc.ServiceCall call, $0.StreamTeamsRequest request);
}
