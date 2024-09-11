import 'dart:async';
import 'dart:convert';

import 'package:echo_tree_flutter/db/checksum.dart';
import 'package:echo_tree_flutter/db/managed_tree/managed_tree_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SP_Wrapper {
  SharedPreferences? _ls;

  // check if shared preferences is ready
  bool get _isReady => _ls != null ? true : false;

  // check if shared preferences is initialized, if not initialize it
  void _checkInitialized() {
    if (!_isReady) {
      SharedPreferences.getInstance().then((ls) => _ls = ls);
    }
  }

  SP_Wrapper() {
    _checkInitialized();
  }

  // get the shared preferences object, and check if it is initialized
  SharedPreferences? get ls {
    _checkInitialized();
    return _ls;
  }
}

class ManagedTree {
  String _treePath;
  _SP_Wrapper _spWrapper = _SP_Wrapper();
  // checksum
  int _checksum = 0;
  final CRC32 _crc32 = CRC32();

  // stream controller
  final StreamController<ManagedTreeEvent> _updatesController = StreamController<ManagedTreeEvent>.broadcast();

  ManagedTree(String treePath) : _treePath = treePath + ":";

  void _updateChecksum() {
    Map<String, String> data = getDataMap();
    if (data.isEmpty) {
      _checksum = 0;
    } else {
      _crc32.calculateChecksum(data).then((value) {
        _checksum = value.toUnsigned(32);
      });
    }
  }

  Future<void> _internalInsert(String path, String value) async {
    await _spWrapper.ls?.setString(path, value);
    _updateChecksum();
  }

  Future<void> _internalRemove(String path) async {
    await _spWrapper.ls?.remove(path);
    _updateChecksum();
  }

  String _internalGet(String path) {
    return _spWrapper.ls?.getString(path) ?? '';
  }

  Map<String, String> getDataMap() {
    // get all keys that start with key
    List<String> keys = _spWrapper.ls?.getKeys().where((k) => k.startsWith(_treePath)).toList() ?? [];

    // just be mindful the keys need to be in order (checksum requires specific order, so keep server and client same)
    List<String> sortedKeys = keys.toList(growable: true)..sort((k1, k2) => k1.compareTo(k2));

    // get the values for the keys
    Map<String, String> data = {};

    for (String k in sortedKeys) {
      // remove the tree path from the key
      String key = k.substring(_treePath.length);
      String? value = _spWrapper.ls?.getString(k);
      if (value != null) {
        data[key] = value;
      }
    }

    return data;
  }

  Future<void> clear() async {
    // get all keys that start with key

    getDataMap().forEach((key, _) async {
      await remove(key);
    });

    _updateChecksum();
  }

  Future<void> setDataMap(Map<String, String> data) async {
    await clear();

    // just be mindful this is a blocking operation, the keys need to be in order (checksum requires specific order, so keep server and client same)
    for (String key in data.keys) {
      await insert(key, data[key] ?? '');
    }

    _updateChecksum();
  }

  // public methods

  // set a value
  Future<void> insert(String key, String value) async {
    await _internalInsert(_treePath + key, value).then((_) {
      _updatesController.add(ManagedTreeEvent(key, value, false));
    });
  }

  // remove a value
  Future<void> remove(String key) async {
    await _internalRemove(_treePath + key).then((_) {
      _updatesController.add(ManagedTreeEvent(key, null, true));
    });
  }

  // get a value
  String get(String key) {
    return _internalGet(_treePath + key);
  }

  void forEach(void Function(String, String) f) {
    getDataMap().forEach(f);
  }

  // checksum
  int get checksum => _checksum;
  String get getAsJson => jsonEncode(getDataMap());
  Stream<ManagedTreeEvent> get updateStream => _updatesController.stream;
}
