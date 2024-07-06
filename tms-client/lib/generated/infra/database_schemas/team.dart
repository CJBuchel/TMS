// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `default`, `fmt`

class Team {
  final String cloudId;
  final String number;
  final String name;
  final String affiliation;
  final int ranking;

  const Team({
    required this.cloudId,
    required this.number,
    required this.name,
    required this.affiliation,
    required this.ranking,
  });

  static Team fromJsonString({required String json}) => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasTeamTeamFromJsonString(json: json);

  String toJsonString() =>
      TmsRustLib.instance.api.crateInfraDatabaseSchemasTeamTeamToJsonString(
        that: this,
      );

  static String toSchema() =>
      TmsRustLib.instance.api.crateInfraDatabaseSchemasTeamTeamToSchema();

  @override
  int get hashCode =>
      cloudId.hashCode ^
      number.hashCode ^
      name.hashCode ^
      affiliation.hashCode ^
      ranking.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Team &&
          runtimeType == other.runtimeType &&
          cloudId == other.cloudId &&
          number == other.number &&
          name == other.name &&
          affiliation == other.affiliation &&
          ranking == other.ranking;
}