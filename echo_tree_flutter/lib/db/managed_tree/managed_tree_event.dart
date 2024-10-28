class ManagedTreeEvent {
  // the key of the changed entry
  final String key;

  // the value of the changed entry (null if deleted)
  final String? value;

  // if the entry was deleted
  final bool deleted;

  ManagedTreeEvent(this.key, this.value, this.deleted);

  @override
  bool operator ==(Object other) {
    if (other is ManagedTreeEvent) {
      return other.key == key && other.value == value;
    }
    return false;
  }

  @override
  int get hashCode => runtimeType.hashCode ^ key.hashCode ^ value.hashCode;

  @override
  String toString() {
    return 'ManagedTreeEvent{key: $key, value: $value, deleted: $deleted}';
  }
}
