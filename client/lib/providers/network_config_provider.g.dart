// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServerIp)
const serverIpProvider = ServerIpProvider._();

final class ServerIpProvider extends $NotifierProvider<ServerIp, String> {
  const ServerIpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverIpProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverIpHash();

  @$internal
  @override
  ServerIp create() => ServerIp();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$serverIpHash() => r'e10458d370fbe4133d59044d5d0808a0ed79ea0d';

abstract class _$ServerIp extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ServerWebPort)
const serverWebPortProvider = ServerWebPortProvider._();

final class ServerWebPortProvider
    extends $NotifierProvider<ServerWebPort, int> {
  const ServerWebPortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverWebPortProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverWebPortHash();

  @$internal
  @override
  ServerWebPort create() => ServerWebPort();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$serverWebPortHash() => r'f1e26a075463f206621e0628d4826a5536c47ead';

abstract class _$ServerWebPort extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ServerApiPort)
const serverApiPortProvider = ServerApiPortProvider._();

final class ServerApiPortProvider
    extends $NotifierProvider<ServerApiPort, int> {
  const ServerApiPortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverApiPortProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverApiPortHash();

  @$internal
  @override
  ServerApiPort create() => ServerApiPort();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$serverApiPortHash() => r'3a4dcd4eb6eec881d32612abfd67f0a04c24246e';

abstract class _$ServerApiPort extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(Tls)
const tlsProvider = TlsProvider._();

final class TlsProvider extends $NotifierProvider<Tls, bool> {
  const TlsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tlsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tlsHash();

  @$internal
  @override
  Tls create() => Tls();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$tlsHash() => r'910879680948d51ce7d5070ce3f08786bd295571';

abstract class _$Tls extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(serverAddress)
const serverAddressProvider = ServerAddressProvider._();

final class ServerAddressProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  const ServerAddressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverAddressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverAddressHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return serverAddress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$serverAddressHash() => r'25f26a5b5ddb89fc56f847acf8dc1daa95a25d43';
