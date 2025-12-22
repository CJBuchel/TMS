// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_validator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that monitors app lifecycle and validates token when app resumes

@ProviderFor(TokenValidator)
const tokenValidatorProvider = TokenValidatorProvider._();

/// Provider that monitors app lifecycle and validates token when app resumes
final class TokenValidatorProvider
    extends $NotifierProvider<TokenValidator, void> {
  /// Provider that monitors app lifecycle and validates token when app resumes
  const TokenValidatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenValidatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenValidatorHash();

  @$internal
  @override
  TokenValidator create() => TokenValidator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$tokenValidatorHash() => r'e48062a95763292b995217b1e9f94c9c43fedd98';

/// Provider that monitors app lifecycle and validates token when app resumes

abstract class _$TokenValidator extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
