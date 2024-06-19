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
    _checksum = _crc32.calculateChecksum(data).toUnsigned(32);
  }

  Future<void> clear() async {
    List<String> keys = _spWrapper.ls?.getKeys().where((k) => k.startsWith(_treePath)).toList() ?? [];

    List<Future> futures = [];
    keys.forEach((key) {
      futures.add(remove(key));
    });

    await Future.wait(futures);

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

  // set a value
  Future<void> insert(String key, String value) async {
    await _spWrapper.ls?.setString(_treePath + key, value).then((_) {
      _updatesController.add(ManagedTreeEvent(key, value, false));
    });
    _updateChecksum();
  }

  // remove a value
  Future<void> remove(String key) async {
    await _spWrapper.ls?.remove(_treePath + key).then((_) {
      _updatesController.add(ManagedTreeEvent(key, null, true));
    });
    _updateChecksum();
  }

  // get a value
  String get(String key) {
    return _spWrapper.ls?.getString(_treePath + key) ?? '';
  }

  void forEach(void Function(String, String) f) {
    getDataMap().forEach(f);
  }

  // checksum
  int get checksum => _checksum;
  String get getAsJson => jsonEncode(getDataMap());
  Stream<ManagedTreeEvent> get updateStream => _updatesController.stream;
}
