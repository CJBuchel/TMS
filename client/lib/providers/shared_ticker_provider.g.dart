// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_ticker_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared ticker that emits the current DateTime at a configurable interval.
/// Multiple widgets using the same interval will share the same ticker.

@ProviderFor(sharedTicker)
const sharedTickerProvider = SharedTickerFamily._();

/// Shared ticker that emits the current DateTime at a configurable interval.
/// Multiple widgets using the same interval will share the same ticker.

final class SharedTickerProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, Stream<DateTime>>
    with $FutureModifier<DateTime>, $StreamProvider<DateTime> {
  /// Shared ticker that emits the current DateTime at a configurable interval.
  /// Multiple widgets using the same interval will share the same ticker.
  const SharedTickerProvider._({
    required SharedTickerFamily super.from,
    required Duration super.argument,
  }) : super(
         retry: null,
         name: r'sharedTickerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sharedTickerHash();

  @override
  String toString() {
    return r'sharedTickerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime> create(Ref ref) {
    final argument = this.argument as Duration;
    return sharedTicker(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SharedTickerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sharedTickerHash() => r'322b78d48060be660a5bc23f7a52707ea3ffffe6';

/// Shared ticker that emits the current DateTime at a configurable interval.
/// Multiple widgets using the same interval will share the same ticker.

final class SharedTickerFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DateTime>, Duration> {
  const SharedTickerFamily._()
    : super(
        retry: null,
        name: r'sharedTickerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Shared ticker that emits the current DateTime at a configurable interval.
  /// Multiple widgets using the same interval will share the same ticker.

  SharedTickerProvider call(Duration interval) =>
      SharedTickerProvider._(argument: interval, from: this);

  @override
  String toString() => r'sharedTickerProvider';
}
