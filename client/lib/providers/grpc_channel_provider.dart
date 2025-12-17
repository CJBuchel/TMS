import 'package:flutter/foundation.dart';
import 'package:grpc/service_api.dart';
import 'package:grpc/grpc_web.dart' as web_grpc;
import 'package:grpc/grpc.dart' as grpc;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/providers/network_config_provider.dart';
import 'package:tms_client/utils/logger.dart';

part 'grpc_channel_provider.g.dart';

@riverpod
class GrpcChannel extends _$GrpcChannel {
  ClientChannel _createWebChannel(String host, int port, bool tls) {
    final protocol = tls ? 'https' : 'http';
    return web_grpc.GrpcWebClientChannel.xhr(
      Uri.parse('$protocol://$host:$port'),
    );
  }

  ClientChannel _createNativeChannel(String host, int port, bool tls) {
    final credentials = tls
        ? grpc.ChannelCredentials.secure()
        : grpc.ChannelCredentials.insecure();

    return grpc.ClientChannel(
      host,
      port: port,
      options: grpc.ChannelOptions(
        credentials: credentials,
        keepAlive: grpc.ClientKeepAliveOptions(
          timeout: Duration(seconds: 10),
          pingInterval: Duration(seconds: 10),
          permitWithoutCalls: true,
        ),
        connectionTimeout: Duration(seconds: 10),
      ),
    );
  }

  void reconnect() {
    logger.i('Reconnecting gRPC channel on next access...');
    ref.invalidateSelf();
  }

  @override
  ClientChannel build() {
    final serverIp = ref.watch(serverIpProvider);
    final apiPort = ref.watch(serverApiPortProvider);
    final tls = ref.watch(tlsProvider);

    final channel = (kIsWeb || kIsWasm)
        ? _createWebChannel(serverIp, apiPort, tls)
        : _createNativeChannel(serverIp, apiPort, tls);

    ref.onDispose(() {
      channel.shutdown();
    });

    logger.i('gRPC channel created: $serverIp:$apiPort (TLS: $tls)');
    return channel;
  }
}
