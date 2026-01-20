import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/generated/api/game_match.pbgrpc.dart';
import 'package:tms_client/generated/db/db.pb.dart';
import 'package:tms_client/helpers/auth_interceptor.dart';
import 'package:tms_client/helpers/collection_storage.dart';
import 'package:tms_client/helpers/reconnecting_stream.dart';
import 'package:tms_client/providers/auth_provider.dart';
import 'package:tms_client/providers/grpc_channel_provider.dart';

part 'match_provider.g.dart';

@Riverpod(keepAlive: true)
GameMatchServiceClient gameMatchService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return GameMatchServiceClient(channel, options: options);
}

@riverpod
Stream<StreamMatchesResponse> matchesStream(Ref ref) {
  final reconnectingStream = ReconnectingStream<StreamMatchesResponse>(
    () async {
      final client = ref.read(gameMatchServiceProvider);
      return client.streamMatches(StreamMatchesRequest());
    },
  );

  ref.onDispose(reconnectingStream.close);
  return reconnectingStream.stream;
}

@Riverpod(keepAlive: true)
class Matches extends _$Matches {
  late final CollectionStorage<GameMatch> _storage;

  @override
  Map<String, GameMatch> build() {
    _storage = CollectionStorage(
      tableName: 'game_matches',
      fromBuffer: GameMatch.fromBuffer,
    );

    // Load from local storage
    final localMatches = _storage.getAll();

    // Bind to stream updates
    _storage.bindToStream(
      ref: ref,
      streamProvider: matchesStreamProvider,
      extractItems: (response) => response.gameMatches,
      hasItem: (item) => item.hasGameMatch(),
      getId: (item) => item.id,
      getItem: (item) => item.gameMatch,
      onUpdate: (updates) => state = {...state, ...updates},
    );

    return localMatches;
  }
}

@riverpod
Map<String, GameMatch> completedMatches(Ref ref) {
  final matches = ref.watch(matchesProvider);
  return Map.fromEntries(
    matches.entries.where((entry) => entry.value.completed),
  );
}

@riverpod
Map<String, GameMatch> incompleteMatches(Ref ref) {
  final matches = ref.watch(matchesProvider);
  return Map.fromEntries(
    matches.entries.where((entry) => !entry.value.completed),
  );
}

@riverpod
Map<String, GameMatch> notFullyScoredMatches(Ref ref) {
  final matches = ref.watch(matchesProvider);
  return Map.fromEntries(
    matches.entries.where(
      (entry) =>
          entry.value.completed &&
          !entry.value.assignments.every((a) => a.scoreSubmitted),
    ),
  );
}

@riverpod
Map<String, GameMatch> fullyScoredMatches(Ref ref) {
  final matches = ref.watch(matchesProvider);
  return Map.fromEntries(
    matches.entries.where(
      (entry) =>
          entry.value.completed &&
          entry.value.assignments.every((a) => a.scoreSubmitted),
    ),
  );
}
