// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gameMatchService)
const gameMatchServiceProvider = GameMatchServiceProvider._();

final class GameMatchServiceProvider
    extends
        $FunctionalProvider<
          GameMatchServiceClient,
          GameMatchServiceClient,
          GameMatchServiceClient
        >
    with $Provider<GameMatchServiceClient> {
  const GameMatchServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameMatchServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameMatchServiceHash();

  @$internal
  @override
  $ProviderElement<GameMatchServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GameMatchServiceClient create(Ref ref) {
    return gameMatchService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameMatchServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameMatchServiceClient>(value),
    );
  }
}

String _$gameMatchServiceHash() => r'f9ca00cb13e961e433d73334dae8ec399e8355b7';

@ProviderFor(matchesStream)
const matchesStreamProvider = MatchesStreamProvider._();

final class MatchesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreamMatchesResponse>,
          StreamMatchesResponse,
          Stream<StreamMatchesResponse>
        >
    with
        $FutureModifier<StreamMatchesResponse>,
        $StreamProvider<StreamMatchesResponse> {
  const MatchesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchesStreamHash();

  @$internal
  @override
  $StreamProviderElement<StreamMatchesResponse> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StreamMatchesResponse> create(Ref ref) {
    return matchesStream(ref);
  }
}

String _$matchesStreamHash() => r'25fcaef4f6a17b1b8488542d979441326897f766';

@ProviderFor(Matches)
const matchesProvider = MatchesProvider._();

final class MatchesProvider
    extends $NotifierProvider<Matches, Map<String, GameMatch>> {
  const MatchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchesHash();

  @$internal
  @override
  Matches create() => Matches();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, GameMatch> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, GameMatch>>(value),
    );
  }
}

String _$matchesHash() => r'60fa8043a2db4d84fbd5f919208bfe85cfefebf6';

abstract class _$Matches extends $Notifier<Map<String, GameMatch>> {
  Map<String, GameMatch> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<Map<String, GameMatch>, Map<String, GameMatch>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, GameMatch>, Map<String, GameMatch>>,
              Map<String, GameMatch>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
