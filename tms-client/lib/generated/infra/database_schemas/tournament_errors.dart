// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.4.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `fmt`, `fmt`

enum TournamentErrorCode {
  e001,
  e002,
  e003,
  e004,
  e005,
  e006,
  e007,
  e008,
  e009,
  e010,
  e011,
  e012,
  ;

  static Future<TournamentErrorCode> default_() => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasTournamentErrorsTournamentErrorCodeDefault();

  static TournamentErrorCode fromJsonString({required String json}) => TmsRustLib
      .instance.api
      .crateInfraDatabaseSchemasTournamentErrorsTournamentErrorCodeFromJsonString(
          json: json);

  String getMessage() => TmsRustLib.instance.api
          .crateInfraDatabaseSchemasTournamentErrorsTournamentErrorCodeGetMessage(
        that: this,
      );

  String getStringifiedCode() => TmsRustLib.instance.api
          .crateInfraDatabaseSchemasTournamentErrorsTournamentErrorCodeGetStringifiedCode(
        that: this,
      );

  String toJsonString() => TmsRustLib.instance.api
          .crateInfraDatabaseSchemasTournamentErrorsTournamentErrorCodeToJsonString(
        that: this,
      );

  static String toSchema() => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasTournamentErrorsTournamentErrorCodeToSchema();
}
