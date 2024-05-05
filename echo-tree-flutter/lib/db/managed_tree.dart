import 'dart:async';
import 'dart:convert';

import 'package:echo_tree_flutter/db/checksum.dart';
import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:hive/hive.dart';

class ManagedTree {
  Box? _box;
  int _checksum = 0;
  String? _treeName;
  final CRC32 _crc32 = CRC32();

  final StreamController<Map<String, dynamic>> _updatesController = StreamController<Map<String, dynamic>>.broadcast();

  ManagedTree({String? treeName}) {
    EchoTreeLogger().d("Creating new tree: $treeName");
    if (treeName != null) {
      _setTreeName(treeName);
    }
  }

  void _treeListener(BoxEvent event) {
    updateChecksum();
    if (event.deleted) {
      _updatesController.add({event.key: null});
    } else {
      final value = _box?.get(event.key);
      _updatesController.add({event.key: value});
    }
  }

  void _setTreeName(String treeName) {
    if (treeName.contains('/')) {
      throw Exception("Invalid tree name: $treeName, cannot contain '/', use ':' instead.");
    } else {
      _treeName = treeName;
    }
  }

  void updateChecksum() {
    if (_box != null) {
      final Map<String, String> data = {};
      var boxMap = _box!.toMap();

      for (var key in boxMap.keys) {
        data[key] = boxMap[key];
      }

      // calculate the checksum
      _checksum = _crc32.calculateChecksum(data).toUnsigned(32);
    }
  }

  Future<void> open({String? treeName}) async {
    if (treeName != null) {
      _setTreeName(treeName);
    }

    if (_treeName == null) {
      EchoTreeLogger().w("Tree name is null, cannot open tree");
      return;
    }

    if (Hive.isBoxOpen(_treeName!)) {
      EchoTreeLogger().w("Tree already open: $_treeName");
      _box = Hive.box(_treeName!);
      return;
    }

    EchoTreeLogger().i("opening tree: $_treeName...");

    _box = await Hive.openBox(_treeName!);
    updateChecksum();

    if (_box != null) {
      EchoTreeLogger().d("Tree opened: $_treeName, box is not null...");
      _box?.watch().listen(_treeListener);
    } else {
      EchoTreeLogger().w("box is null after being created: $_treeName...");
    }
  }

  Future<void> insert(String key, String value) async {
    if (_box != null) {
      EchoTreeLogger().d("Inserting into tree: $_treeName, key: $key, value: $value");
      await _box!.put(key, value);
    } else {
      EchoTreeLogger().w("box is null, try opening it first: $_treeName...");
    }
  }

  String get(String key) {
    if (_box != null) {
      return _box!.get(key);
    }
    return '';
  }

  Future<void> remove(String key) async {
    if (_box != null) {
      await _box!.delete(key);
    }
  }

  Future<int> clear() async {
    int r = 0;
    if (_box != null) {
      r = await _box!.clear();
    } else {
      r = 0;
    }

    return r;
  }

  Future<void> drop() async {
    clear();
    if (_box != null) {
      _box!.deleteFromDisk();
      _updatesController.close();
    }
  }

  Future<void> setFromHashmap(Map<String, String> map) async {
    EchoTreeLogger().d("Setting tree from hashmap: $_treeName");
    if (_box != null) {
      await clear();
      List<Future> futures = [];
      map.forEach((key, value) {
        futures.add(insert(key, value));
      });
      await Future.wait(futures);
    } else {
      EchoTreeLogger().w("box is null, try opening it first: $_treeName..., checksum: $_checksum");
    }
  }

  Map<String, String> get getAsHashmap {
    Map<String, String> map = {};
    if (_box != null) {
      _box!.toMap().forEach((key, value) {
        map[key] = value;
      });
    } else {
      EchoTreeLogger().w("box is null, try opening it first: $_treeName...");
    }
    return map;
  }

  void forEach(void Function(String, String) f) {
    if (_box != null) {
      _box!.toMap().forEach((key, value) {
        f(key, value);
      });
    }
  }

  String get getAsJson => jsonEncode(getAsHashmap);
  String get getName => _treeName ?? '';
  Stream<Map<String, dynamic>> get updates => _updatesController.stream;
  int get getChecksum => _checksum;
  bool get isOpen {
    if (_box != null) {
      return _box!.isOpen;
    }
    return false;
  }
}
