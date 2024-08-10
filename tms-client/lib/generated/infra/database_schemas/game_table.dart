// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.2.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `fmt`

class GameTable {
  final String tableName;

  const GameTable({
    required this.tableName,
  });

  static Future<GameTable> default_() => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasGameTableGameTableDefault();

  static GameTable fromJsonString({required String json}) => TmsRustLib
      .instance.api
      .crateInfraDatabaseSchemasGameTableGameTableFromJsonString(json: json);

  String toJsonString() => TmsRustLib.instance.api
          .crateInfraDatabaseSchemasGameTableGameTableToJsonString(
        that: this,
      );

  static String toSchema() => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasGameTableGameTableToSchema();

  @override
  int get hashCode => tableName.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameTable &&
          runtimeType == other.runtimeType &&
          tableName == other.tableName;
}
