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

  int calculateChecksum(Map<String, String> data) {
    int crc = 0xFFFFFFFF;
    data.forEach((key, value) {
      final bytes = [...key.codeUnits, ...value.codeUnits];
      for (var byte in bytes) {
        final byteIndex = (crc ^ byte) & 0xFF;
        crc = _table[byteIndex] ^ (crc >> 8);
      }
    });
    return ~crc;
  }
}
