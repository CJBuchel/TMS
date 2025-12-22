// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(healthService)
const healthServiceProvider = HealthServiceProvider._();

final class HealthServiceProvider
    extends
        $FunctionalProvider<
          HealthServiceClient,
          HealthServiceClient,
          HealthServiceClient
        >
    with $Provider<HealthServiceClient> {
  const HealthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthServiceHash();

  @$internal
  @override
  $ProviderElement<HealthServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HealthServiceClient create(Ref ref) {
    return healthService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthServiceClient>(value),
    );
  }
}

String _$healthServiceHash() => r'14d38fb6c1bdce03a96070f98ef74adf2a2d2e23';

@ProviderFor(isConnected)
const isConnectedProvider = IsConnectedProvider._();

final class IsConnectedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  const IsConnectedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isConnectedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isConnectedHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return isConnected(ref);
  }
}

String _$isConnectedHash() => r'e0561f30c954ed9fa13ec4144e995739b7d83ce2';
