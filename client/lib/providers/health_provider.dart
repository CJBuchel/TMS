import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/generated/api/api.pbgrpc.dart';
import 'package:tms_client/helpers/reconnecting_stream.dart';
import 'package:tms_client/providers/grpc_channel_provider.dart';

part 'health_provider.g.dart';

@Riverpod(keepAlive: true)
HealthServiceClient healthService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  return HealthServiceClient(channel);
}

@Riverpod(keepAlive: true)
Stream<bool> isConnected(Ref ref) {
  final reconnectingStream = ReconnectingStream<GetHealthResponse>(() async {
    final client = ref.read(healthServiceProvider);
    return client.streamHealth(GetHealthRequest());
  });

  ref.onDispose(reconnectingStream.close);
  return reconnectingStream.connectionState;
}
