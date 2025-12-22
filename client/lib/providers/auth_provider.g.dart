// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Token)
const tokenProvider = TokenProvider._();

final class TokenProvider extends $NotifierProvider<Token, String?> {
  const TokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenHash();

  @$internal
  @override
  Token create() => Token();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$tokenHash() => r'417412ee1a3b9982f5454a22f48671832629a6ef';

abstract class _$Token extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(Username)
const usernameProvider = UsernameProvider._();

final class UsernameProvider extends $NotifierProvider<Username, String?> {
  const UsernameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usernameProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usernameHash();

  @$internal
  @override
  Username create() => Username();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$usernameHash() => r'6f440800238e9bf2bfdd1380de34f206ffa172b7';

abstract class _$Username extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(Roles)
const rolesProvider = RolesProvider._();

final class RolesProvider extends $NotifierProvider<Roles, List<Role>> {
  const RolesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rolesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rolesHash();

  @$internal
  @override
  Roles create() => Roles();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Role> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Role>>(value),
    );
  }
}

String _$rolesHash() => r'76b762e570f745fb5e48fc79e94784f42e7e2669';

abstract class _$Roles extends $Notifier<List<Role>> {
  List<Role> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Role>, List<Role>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Role>, List<Role>>,
              List<Role>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(UserService)
const userServiceProvider = UserServiceProvider._();

final class UserServiceProvider
    extends $NotifierProvider<UserService, UserServiceClient> {
  const UserServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userServiceHash();

  @$internal
  @override
  UserService create() => UserService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserServiceClient>(value),
    );
  }
}

String _$userServiceHash() => r'72ab69d62237bc6575facc9e0b835be36a919bd1';

abstract class _$UserService extends $Notifier<UserServiceClient> {
  UserServiceClient build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UserServiceClient, UserServiceClient>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserServiceClient, UserServiceClient>,
              UserServiceClient,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(isLoggedIn)
const isLoggedInProvider = IsLoggedInProvider._();

final class IsLoggedInProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const IsLoggedInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isLoggedInProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isLoggedInHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isLoggedIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isLoggedInHash() => r'55854175bbde37cc8bbce06e9d85b2e4f6cb5a39';
