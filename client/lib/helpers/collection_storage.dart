import 'package:protobuf/protobuf.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/helpers/local_storage.dart';
import 'package:tms_client/helpers/protobuf_helper.dart';

/// Helper for storing and retrieving collections of protobuf messages.
///
/// Each item is stored individually with a prefixed key, making updates
/// efficient. An index tracks all IDs in the collection.
class CollectionStorage<T extends GeneratedMessage> {
  final String tableName;
  final T Function(List<int>) fromBuffer;

  CollectionStorage({required this.tableName, required this.fromBuffer});

  String get _idsKey => '${tableName}_ids';
  String _itemKey(String id) => '${tableName}_$id';

  Map<String, T> getAll() {
    final ids = localStorage.getStringList(_idsKey) ?? [];
    final items = <String, T>{};

    for (final id in ids) {
      final item = get(id);
      if (item != null) {
        items[id] = item;
      }
    }

    return items;
  }

  /// Get a single item by ID
  T? get(String id) {
    final encoded = localStorage.getString(_itemKey(id));
    if (encoded == null) return null;

    try {
      return ProtobufHelper.decode(encoded, fromBuffer);
    } catch (e) {
      return null;
    }
  }

  /// Save a single item
  Future<void> set(String id, T item) async {
    final encoded = ProtobufHelper.encode(item);
    await localStorage.setString(_itemKey(id), encoded);

    // Add to index if not already present
    final ids = localStorage.getStringList(_idsKey) ?? [];
    if (!ids.contains(id)) {
      ids.add(id);
      await localStorage.setStringList(_idsKey, ids);
    }
  }

  /// Save multiple items
  Future<void> setAll(Map<String, T> items) async {
    final ids = <String>[];

    for (final entry in items.entries) {
      final encoded = ProtobufHelper.encode(entry.value);
      await localStorage.setString(_itemKey(entry.key), encoded);
      ids.add(entry.key);
    }

    await localStorage.setStringList(_idsKey, ids);
  }

  /// Remove a single item
  Future<void> remove(String id) async {
    await localStorage.remove(_itemKey(id));

    final ids = localStorage.getStringList(_idsKey) ?? [];
    ids.remove(id);
    await localStorage.setStringList(_idsKey, ids);
  }

  /// Clear all items in this collection
  Future<void> clear() async {
    final ids = localStorage.getStringList(_idsKey) ?? [];

    // Remove all individual items
    for (final id in ids) {
      await localStorage.remove(_itemKey(id));
    }

    // Clear the index
    await localStorage.remove(_idsKey);
  }

  /// Get list of all IDs
  List<String> getIds() {
    return localStorage.getStringList(_idsKey) ?? [];
  }

  /// Check if an item exists
  bool exists(String id) {
    final ids = localStorage.getStringList(_idsKey) ?? [];
    return ids.contains(id);
  }

  /// Process stream updates and return a map of changes.
  ///
  /// Takes an iterable of response items and a callback:
  /// - extractIdAndItem: Given a response item, returns (id, item) if valid, or null to skip
  ///
  /// Returns a map of all items that were updated.
  Map<String, T> processStreamUpdates<R>(
    Iterable<R> responseItems,
    (String, T)? Function(R) extractIdAndItem,
  ) {
    final updates = <String, T>{};

    for (final responseItem in responseItems) {
      final result = extractIdAndItem(responseItem);
      if (result != null) {
        final (id, item) = result;
        set(id, item);
        updates[id] = item;
      }
    }

    return updates;
  }

  /// Sets up a listener for stream updates that automatically syncs with storage and state.
  ///
  /// Parameters:
  /// - ref: The Riverpod ref
  /// - streamProvider: The stream provider to listen to
  /// - extractItems: Function to extract the list of response items from the stream response
  /// - hasItem: Function to check if a response item has the actual data (e.g., hasGameMatch())
  /// - getId: Function to extract the ID from a response item
  /// - getItem: Function to extract the actual item from a response item
  /// - onUpdate: Optional callback when state should be updated with new items
  /// - onError: Optional callback when an error occurs
  void bindToStream<StreamResponse, ResponseItem>({
    required Ref ref,
    required ProviderListenable<AsyncValue<StreamResponse>> streamProvider,
    required Iterable<ResponseItem> Function(StreamResponse) extractItems,
    required bool Function(ResponseItem) hasItem,
    required String Function(ResponseItem) getId,
    required T Function(ResponseItem) getItem,
    void Function(Map<String, T> updates)? onUpdate,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    ref.listen(streamProvider, (previous, next) {
      next.when(
        data: (response) {
          final items = extractItems(response);
          final updates = processStreamUpdates(
            items,
            (responseItem) => hasItem(responseItem)
                ? (getId(responseItem), getItem(responseItem))
                : null,
          );

          if (updates.isNotEmpty && onUpdate != null) {
            onUpdate(updates);
          }
        },
        loading: () {},
        error: (error, stack) {
          if (onError != null) {
            onError(error, stack);
          }
          // On error, continue using local storage
        },
      );
    });
  }
}
