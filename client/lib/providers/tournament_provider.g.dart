// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tournamentService)
const tournamentServiceProvider = TournamentServiceProvider._();

final class TournamentServiceProvider
    extends
        $FunctionalProvider<
          TournamentServiceClient,
          TournamentServiceClient,
          TournamentServiceClient
        >
    with $Provider<TournamentServiceClient> {
  const TournamentServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tournamentServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tournamentServiceHash();

  @$internal
  @override
  $ProviderElement<TournamentServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TournamentServiceClient create(Ref ref) {
    return tournamentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TournamentServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TournamentServiceClient>(value),
    );
  }
}

String _$tournamentServiceHash() => r'ff12460c01631a990cbb514f0dd846fdd6c20860';

@ProviderFor(tournamentStream)
const tournamentStreamProvider = TournamentStreamProvider._();

final class TournamentStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreamTournamentResponse>,
          StreamTournamentResponse,
          Stream<StreamTournamentResponse>
        >
    with
        $FutureModifier<StreamTournamentResponse>,
        $StreamProvider<StreamTournamentResponse> {
  const TournamentStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tournamentStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tournamentStreamHash();

  @$internal
  @override
  $StreamProviderElement<StreamTournamentResponse> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StreamTournamentResponse> create(Ref ref) {
    return tournamentStream(ref);
  }
}

String _$tournamentStreamHash() => r'020f04e5e8a72e0282099943699b6f8816f3ac71';
