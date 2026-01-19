// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(teamService)
const teamServiceProvider = TeamServiceProvider._();

final class TeamServiceProvider
    extends
        $FunctionalProvider<
          TeamServiceClient,
          TeamServiceClient,
          TeamServiceClient
        >
    with $Provider<TeamServiceClient> {
  const TeamServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamServiceHash();

  @$internal
  @override
  $ProviderElement<TeamServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TeamServiceClient create(Ref ref) {
    return teamService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TeamServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TeamServiceClient>(value),
    );
  }
}

String _$teamServiceHash() => r'b8257fb2da78319419ca1d4c36236487487dcd49';

@ProviderFor(teamsStream)
const teamsStreamProvider = TeamsStreamProvider._();

final class TeamsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreamTeamsResponse>,
          StreamTeamsResponse,
          Stream<StreamTeamsResponse>
        >
    with
        $FutureModifier<StreamTeamsResponse>,
        $StreamProvider<StreamTeamsResponse> {
  const TeamsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamsStreamHash();

  @$internal
  @override
  $StreamProviderElement<StreamTeamsResponse> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StreamTeamsResponse> create(Ref ref) {
    return teamsStream(ref);
  }
}

String _$teamsStreamHash() => r'496c9e7675a4bbd0f11fa8c3993271f0199b93b4';

@ProviderFor(Teams)
const teamsProvider = TeamsProvider._();

final class TeamsProvider extends $NotifierProvider<Teams, Map<String, Team>> {
  const TeamsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamsHash();

  @$internal
  @override
  Teams create() => Teams();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Team> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Team>>(value),
    );
  }
}

String _$teamsHash() => r'eac048dfd51d9986926c83e69e0e858b3a237b0c';

abstract class _$Teams extends $Notifier<Map<String, Team>> {
  Map<String, Team> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Map<String, Team>, Map<String, Team>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, Team>, Map<String, Team>>,
              Map<String, Team>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(team)
const teamProvider = TeamFamily._();

final class TeamProvider extends $FunctionalProvider<Team?, Team?, Team?>
    with $Provider<Team?> {
  const TeamProvider._({
    required TeamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'teamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamHash();

  @override
  String toString() {
    return r'teamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Team?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Team? create(Ref ref) {
    final argument = this.argument as String;
    return team(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Team? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Team?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TeamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamHash() => r'69d256c54ab5c35cc77930fed0d76e1ac3e19723';

final class TeamFamily extends $Family
    with $FunctionalFamilyOverride<Team?, String> {
  const TeamFamily._()
    : super(
        retry: null,
        name: r'teamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TeamProvider call(String id) => TeamProvider._(argument: id, from: this);

  @override
  String toString() => r'teamProvider';
}
