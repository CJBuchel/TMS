import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/generated/api/team.pbgrpc.dart';
import 'package:tms_client/generated/db/db.pb.dart';
import 'package:tms_client/helpers/auth_interceptor.dart';
import 'package:tms_client/helpers/collection_storage.dart';
import 'package:tms_client/helpers/reconnecting_stream.dart';
import 'package:tms_client/providers/auth_provider.dart';
import 'package:tms_client/providers/grpc_channel_provider.dart';
import 'package:tms_client/utils/logger.dart';

part 'team_provider.g.dart';

@Riverpod(keepAlive: true)
TeamServiceClient teamService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return TeamServiceClient(channel, options: options);
}

@riverpod
Stream<StreamTeamsResponse> teamsStream(Ref ref) {
  final reconnectingStream = ReconnectingStream<StreamTeamsResponse>(() async {
    final client = ref.watch(teamServiceProvider);
    return client.streamTeams(StreamTeamsRequest());
  });

  ref.onDispose(reconnectingStream.close);
  return reconnectingStream.stream;
}

@Riverpod(keepAlive: true)
class Teams extends _$Teams {
  late final CollectionStorage<Team> _storage;

  @override
  Map<String, Team> build() {
    _storage = CollectionStorage(
      tableName: 'teams',
      fromBuffer: Team.fromBuffer,
    );

    // Load from local storage
    final localTeams = _storage.getAll();

    // Bind to stream updates
    _storage.bindToStream(
      ref: ref,
      streamProvider: teamsStreamProvider,
      extractItems: (response) => response.teams,
      hasItem: (item) => item.hasTeam(),
      getId: (item) => item.id,
      getItem: (item) => item.team,
      onUpdate: (updates) => state = {...state, ...updates},
    );

    return localTeams;
  }
}

@riverpod
Team? team(Ref ref, String id) {
  final team = ref.watch(teamsProvider.select((teams) => teams[id]));
  return team;
}
