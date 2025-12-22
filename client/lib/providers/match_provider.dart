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

  /// Manually update a single match
  Future<void> updateMatch(String id, GameMatch match) async {
    await _storage.set(id, match);
    state = {...state, id: match};
  }

  /// Remove a match
  Future<void> removeMatch(String id) async {
    await _storage.remove(id);
    final newState = {...state};
    newState.remove(id);
    state = newState;
  }

  /// Clear all matches
  Future<void> clear() async {
    await _storage.clear();
    state = {};
  }

  @override
  Map<String, GameMatch> build() {
    _storage = CollectionStorage(
      tableName: 'game_matches',
      fromBuffer: GameMatch.fromBuffer,
    );

    // Load from local storage
    final localMatches = _storage.getAll();

    // Listen to stream updates
    ref.listen(matchesStreamProvider, (previous, next) {
      next.when(
        data: (response) {
          final updates = <String, GameMatch>{};

          for (final matchResponse in response.gameMatches) {
            if (matchResponse.hasGameMatch()) {
              final id = matchResponse.id;
              final match = matchResponse.gameMatch;

              // Save to local storage
              _storage.set(id, match);
              updates[id] = match;
            }
          }

          // Update state with all changes
          if (updates.isNotEmpty) {
            state = {...state, ...updates};
          }
        },
        loading: () {},
        error: (error, stack) {
          // On error, continue using local storage
        },
      );
    });

    return localMatches;
  }
}
