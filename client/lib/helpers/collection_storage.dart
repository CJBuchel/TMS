import 'package:protobuf/protobuf.dart';
import 'package:tms_client/helpers/local_storage.dart';
import 'package:tms_client/helpers/protobuf_storage.dart';

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
      return ProtobufStorage.decode(encoded, fromBuffer);
    } catch (e) {
      return null;
    }
  }

  /// Save a single item
  Future<void> set(String id, T item) async {
    final encoded = ProtobufStorage.encode(item);
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
      final encoded = ProtobufStorage.encode(entry.value);
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
}
