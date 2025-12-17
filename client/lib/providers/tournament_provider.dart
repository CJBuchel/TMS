import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/generated/api/api.pbgrpc.dart';
import 'package:tms_client/helpers/reconnecting_stream.dart';
import 'package:tms_client/providers/grpc_channel_provider.dart';

part 'tournament_provider.g.dart';

@Riverpod(keepAlive: true)
TournamentServiceClient tournamentService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  return TournamentServiceClient(channel);
}

@riverpod
Stream<StreamTournamentResponse> tournamentStream(Ref ref) {
  final reconnectingStream = ReconnectingStream<StreamTournamentResponse>(
    () async {
      final client = ref.read(tournamentServiceProvider);
      return client.streamTournament(StreamTournamentRequest());
    },
  );

  ref.onDispose(reconnectingStream.close);
  return reconnectingStream.stream;
}
