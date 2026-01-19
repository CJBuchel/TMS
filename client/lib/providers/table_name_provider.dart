import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/generated/api/table_name.pbgrpc.dart';
import 'package:tms_client/generated/db/db.pb.dart';
import 'package:tms_client/helpers/auth_interceptor.dart';
import 'package:tms_client/helpers/collection_storage.dart';
import 'package:tms_client/helpers/reconnecting_stream.dart';
import 'package:tms_client/providers/auth_provider.dart';
import 'package:tms_client/providers/grpc_channel_provider.dart';

part 'table_name_provider.g.dart';

@Riverpod(keepAlive: true)
TableNameServiceClient tableNameService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return TableNameServiceClient(channel, options: options);
}

@riverpod
Stream<StreamTableNamesResponse> tableNamesStream(Ref ref) {
  final reconnectingStream = ReconnectingStream<StreamTableNamesResponse>(
    () async {
      final client = ref.watch(tableNameServiceProvider);
      return client.streamTableNames(StreamTableNamesRequest());
    },
  );

  ref.onDispose(reconnectingStream.close);
  return reconnectingStream.stream;
}

@Riverpod(keepAlive: true)
class TableNames extends _$TableNames {
  late final CollectionStorage<TableName> _storage;

  @override
  Map<String, TableName> build() {
    _storage = CollectionStorage(
      tableName: 'table_names',
      fromBuffer: TableName.fromBuffer,
    );

    // Load from local storage
    final localTableNames = _storage.getAll();

    // Bind to stream updates
    _storage.bindToStream(
      ref: ref,
      streamProvider: tableNamesStreamProvider,
      extractItems: (response) => response.tableNames,
      hasItem: (item) => item.hasTableName(),
      getId: (item) => item.id,
      getItem: (item) => item.tableName,
      onUpdate: (updates) => state = {...state, ...updates},
    );

    return localTableNames;
  }
}

@riverpod
String? tableName(Ref ref, String id) {
  final tableName = ref.watch(
    tableNamesProvider.select((tableNames) => tableNames[id]),
  );
  return tableName?.tableName;
}
