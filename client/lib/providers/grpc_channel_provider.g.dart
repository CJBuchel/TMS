// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grpc_channel_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GrpcChannel)
const grpcChannelProvider = GrpcChannelProvider._();

final class GrpcChannelProvider
    extends $NotifierProvider<GrpcChannel, ClientChannel> {
  const GrpcChannelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'grpcChannelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$grpcChannelHash();

  @$internal
  @override
  GrpcChannel create() => GrpcChannel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientChannel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientChannel>(value),
    );
  }
}

String _$grpcChannelHash() => r'9d81ca665b9f37abc1ee5bfd3df142e2d9dcb623';

abstract class _$GrpcChannel extends $Notifier<ClientChannel> {
  ClientChannel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ClientChannel, ClientChannel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClientChannel, ClientChannel>,
              ClientChannel,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
