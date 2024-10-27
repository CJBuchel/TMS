// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.5.1.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'category.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'tms_time/tms_date.dart';
import 'tms_time/tms_date_time.dart';
import 'tms_time/tms_time.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `clone`, `fmt`, `fmt`

class GameMatch {
  final String matchNumber;
  final TmsDateTime startTime;
  final TmsDateTime endTime;
  final List<GameMatchTable> gameMatchTables;
  final bool completed;
  final TmsCategory category;

  const GameMatch({
    required this.matchNumber,
    required this.startTime,
    required this.endTime,
    required this.gameMatchTables,
    required this.completed,
    required this.category,
  });

  static Future<GameMatch> default_() => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasGameMatchGameMatchDefault();

  static GameMatch fromJsonString({required String json}) => TmsRustLib
      .instance.api
      .crateInfraDatabaseSchemasGameMatchGameMatchFromJsonString(json: json);

  String toJsonString() => TmsRustLib.instance.api
          .crateInfraDatabaseSchemasGameMatchGameMatchToJsonString(
        that: this,
      );

  static String toSchema() => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasGameMatchGameMatchToSchema();

  @override
  int get hashCode =>
      matchNumber.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      gameMatchTables.hashCode ^
      completed.hashCode ^
      category.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameMatch &&
          runtimeType == other.runtimeType &&
          matchNumber == other.matchNumber &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          gameMatchTables == other.gameMatchTables &&
          completed == other.completed &&
          category == other.category;
}

class GameMatchTable {
  final String table;
  final String teamNumber;
  final bool scoreSubmitted;

  const GameMatchTable({
    required this.table,
    required this.teamNumber,
    required this.scoreSubmitted,
  });

  @override
  int get hashCode =>
      table.hashCode ^ teamNumber.hashCode ^ scoreSubmitted.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameMatchTable &&
          runtimeType == other.runtimeType &&
          table == other.table &&
          teamNumber == other.teamNumber &&
          scoreSubmitted == other.scoreSubmitted;
}