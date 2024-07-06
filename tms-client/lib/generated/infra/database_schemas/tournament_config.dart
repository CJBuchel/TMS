// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `default`, `fmt`

class TournamentConfig {
  final String name;
  final int backupInterval;
  final int retainBackups;
  final int endGameTimerLength;
  final int timerLength;
  final String season;

  const TournamentConfig({
    required this.name,
    required this.backupInterval,
    required this.retainBackups,
    required this.endGameTimerLength,
    required this.timerLength,
    required this.season,
  });

  static TournamentConfig fromJsonString({required String json}) => TmsRustLib
      .instance.api
      .crateInfraDatabaseSchemasTournamentConfigTournamentConfigFromJsonString(
          json: json);

  String toJsonString() => TmsRustLib.instance.api
          .crateInfraDatabaseSchemasTournamentConfigTournamentConfigToJsonString(
        that: this,
      );

  static String toSchema() => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasTournamentConfigTournamentConfigToSchema();

  @override
  int get hashCode =>
      name.hashCode ^
      backupInterval.hashCode ^
      retainBackups.hashCode ^
      endGameTimerLength.hashCode ^
      timerLength.hashCode ^
      season.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentConfig &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          backupInterval == other.backupInterval &&
          retainBackups == other.retainBackups &&
          endGameTimerLength == other.endGameTimerLength &&
          timerLength == other.timerLength &&
          season == other.season;
}