import 'dart:convert';

class CRC32 {
  static const int _polynomial = 0xEDB88320;
  late List<int> _table;

  CRC32() {
    _initTable();
  }

  void _initTable() {
    _table = List<int>.filled(256, 0);
    for (int i = 0; i < 256; i++) {
      int crc = i;
      for (int j = 0; j < 8; j++) {
        if (crc & 1 == 1) {
          crc = _polynomial ^ (crc >> 1);
        } else {
          crc = crc >> 1;
        }
      }
      _table[i] = crc;
    }
  }

  Future<int> calculateChecksum(Map<String, String> data) async {
    int crc = 0xFFFFFFFF;
    for (var entry in data.entries) {
      final keyBytes = utf8.encode(entry.key);
      final valueBytes = utf8.encode(entry.value);
      final byteSteam = Stream.fromIterable([keyBytes, valueBytes]);
      await for (var chunk in byteSteam) {
        for (var byte in chunk) {
          final byteIndex = (crc ^ byte) & 0xFF;
          crc = _table[byteIndex] ^ (crc >> 8);
        }
      }
    }
    return ~crc;
  }
}
