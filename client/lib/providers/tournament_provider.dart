import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/generated/api/tournament.pbgrpc.dart';
import 'package:tms_client/helpers/auth_interceptor.dart';
import 'package:tms_client/helpers/reconnecting_stream.dart';
import 'package:tms_client/providers/auth_provider.dart';
import 'package:tms_client/providers/grpc_channel_provider.dart';

part 'tournament_provider.g.dart';

@Riverpod(keepAlive: true)
TournamentServiceClient tournamentService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return TournamentServiceClient(channel, options: options);
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
