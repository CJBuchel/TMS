import 'dart:convert';
import 'package:protobuf/protobuf.dart';

/// Protobuf messages are serialized to binary, then encoded as base64 strings
/// for compatibility with SharedPreferences (which only supports strings).
class ProtobufHelper {
  /// Encode a single protobuf message to a base64 string
  static String encode<T extends GeneratedMessage>(T message) {
    final bytes = message.writeToBuffer();
    return base64Encode(bytes);
  }

  /// Decode a base64 string back to a protobuf message
  static T decode<T extends GeneratedMessage>(
    String encoded,
    T Function(List<int>) fromBuffer,
  ) {
    final bytes = base64Decode(encoded);
    return fromBuffer(bytes);
  }

  /// Encode a list of protobuf messages to a list of base64 strings
  static List<String> encodeList<T extends GeneratedMessage>(List<T> messages) {
    return messages.map((message) => encode(message)).toList();
  }

  /// Decode a list of base64 strings back to protobuf messages
  ///
  /// Skips any messages that fail to parse (corrupted data)
  static List<T> decodeList<T extends GeneratedMessage>(
    List<String> encoded,
    T Function(List<int>) fromBuffer,
  ) {
    return encoded
        .map((str) {
          try {
            return decode(str, fromBuffer);
          } catch (e) {
            // Skip corrupted entries
            return null;
          }
        })
        .whereType<T>()
        .toList();
  }

  /// Safely decode a list, returning an empty list on any error
  static List<T> decodeListSafe<T extends GeneratedMessage>(
    List<String>? encoded,
    T Function(List<int>) fromBuffer,
  ) {
    if (encoded == null || encoded.isEmpty) return [];
    return decodeList(encoded, fromBuffer);
  }
}
