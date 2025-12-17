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
        isAutoDispose: true,
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

String _$tokenHash() => r'742c6f0dceed47fd21ef483ee5bd1cfbe84452eb';

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
        isAutoDispose: true,
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

String _$usernameHash() => r'95c4763340cdefacdd4ccc2c1ed2448f5465f816';

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
        isAutoDispose: true,
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

String _$rolesHash() => r'cb924bdd7f7fd257384cc0420c42e6812016abfe';

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

String _$userServiceHash() => r'c92f265675be028f4701ad494b6609a421b878ab';

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
        isAutoDispose: true,
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

String _$isLoggedInHash() => r'b7ba28896cfb94019d6b962a2ee1c7392d3171ae';
