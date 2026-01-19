// This is a generated file - do not edit.
//
// Generated from api/table_name.proto.

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

import 'table_name.pb.dart' as $0;

export 'table_name.pb.dart';

@$pb.GrpcServiceName('tms.api.TableNameService')
class TableNameServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TableNameServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$0.StreamTableNamesResponse> streamTableNames(
    $0.StreamTableNamesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamTableNames, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$streamTableNames = $grpc.ClientMethod<
          $0.StreamTableNamesRequest, $0.StreamTableNamesResponse>(
      '/tms.api.TableNameService/StreamTableNames',
      ($0.StreamTableNamesRequest value) => value.writeToBuffer(),
      $0.StreamTableNamesResponse.fromBuffer);
}

@$pb.GrpcServiceName('tms.api.TableNameService')
abstract class TableNameServiceBase extends $grpc.Service {
  $core.String get $name => 'tms.api.TableNameService';

  TableNameServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.StreamTableNamesRequest,
            $0.StreamTableNamesResponse>(
        'StreamTableNames',
        streamTableNames_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamTableNamesRequest.fromBuffer(value),
        ($0.StreamTableNamesResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.StreamTableNamesResponse> streamTableNames_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamTableNamesRequest> $request) async* {
    yield* streamTableNames($call, await $request);
  }

  $async.Stream<$0.StreamTableNamesResponse> streamTableNames(
      $grpc.ServiceCall call, $0.StreamTableNamesRequest request);
}
