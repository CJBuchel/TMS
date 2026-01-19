// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_name_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tableNameService)
const tableNameServiceProvider = TableNameServiceProvider._();

final class TableNameServiceProvider
    extends
        $FunctionalProvider<
          TableNameServiceClient,
          TableNameServiceClient,
          TableNameServiceClient
        >
    with $Provider<TableNameServiceClient> {
  const TableNameServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tableNameServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tableNameServiceHash();

  @$internal
  @override
  $ProviderElement<TableNameServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TableNameServiceClient create(Ref ref) {
    return tableNameService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TableNameServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TableNameServiceClient>(value),
    );
  }
}

String _$tableNameServiceHash() => r'c2bb88d5951eace565309f20b37994fdbd09a6ce';

@ProviderFor(tableNamesStream)
const tableNamesStreamProvider = TableNamesStreamProvider._();

final class TableNamesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreamTableNamesResponse>,
          StreamTableNamesResponse,
          Stream<StreamTableNamesResponse>
        >
    with
        $FutureModifier<StreamTableNamesResponse>,
        $StreamProvider<StreamTableNamesResponse> {
  const TableNamesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tableNamesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tableNamesStreamHash();

  @$internal
  @override
  $StreamProviderElement<StreamTableNamesResponse> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StreamTableNamesResponse> create(Ref ref) {
    return tableNamesStream(ref);
  }
}

String _$tableNamesStreamHash() => r'c17775b12a639d93bf72b671053785da078fa6dc';

@ProviderFor(TableNames)
const tableNamesProvider = TableNamesProvider._();

final class TableNamesProvider
    extends $NotifierProvider<TableNames, Map<String, TableName>> {
  const TableNamesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tableNamesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tableNamesHash();

  @$internal
  @override
  TableNames create() => TableNames();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, TableName> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, TableName>>(value),
    );
  }
}

String _$tableNamesHash() => r'e6a68d861bb88acbadd8b3145e8fdfd95efc0af2';

abstract class _$TableNames extends $Notifier<Map<String, TableName>> {
  Map<String, TableName> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<Map<String, TableName>, Map<String, TableName>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, TableName>, Map<String, TableName>>,
              Map<String, TableName>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(tableName)
const tableNameProvider = TableNameFamily._();

final class TableNameProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  const TableNameProvider._({
    required TableNameFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tableNameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tableNameHash();

  @override
  String toString() {
    return r'tableNameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    final argument = this.argument as String;
    return tableName(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TableNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tableNameHash() => r'2bdf5e5b1eea57cf142925a2b0d0088e40011f94';

final class TableNameFamily extends $Family
    with $FunctionalFamilyOverride<String?, String> {
  const TableNameFamily._()
    : super(
        retry: null,
        name: r'tableNameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TableNameProvider call(String id) =>
      TableNameProvider._(argument: id, from: this);

  @override
  String toString() => r'tableNameProvider';
}
