// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(scheduleService)
const scheduleServiceProvider = ScheduleServiceProvider._();

final class ScheduleServiceProvider
    extends
        $FunctionalProvider<
          ScheduleServiceClient,
          ScheduleServiceClient,
          ScheduleServiceClient
        >
    with $Provider<ScheduleServiceClient> {
  const ScheduleServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleServiceHash();

  @$internal
  @override
  $ProviderElement<ScheduleServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ScheduleServiceClient create(Ref ref) {
    return scheduleService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScheduleServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScheduleServiceClient>(value),
    );
  }
}

String _$scheduleServiceHash() => r'396cf1895752c49049d977d3449210f7cb3aed55';
