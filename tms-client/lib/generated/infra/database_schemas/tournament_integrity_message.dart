// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.1.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:freezed_annotation/freezed_annotation.dart' hide protected;
import 'tournament_errors.dart';
import 'tournament_warnings.dart';
part 'tournament_integrity_message.freezed.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `clone`, `fmt`, `fmt`

@freezed
sealed class TournamentIntegrityCode with _$TournamentIntegrityCode {
  const TournamentIntegrityCode._();

  const factory TournamentIntegrityCode.error(
    TournamentErrorCode field0,
  ) = TournamentIntegrityCode_Error;
  const factory TournamentIntegrityCode.warning(
    TournamentWarningCode field0,
  ) = TournamentIntegrityCode_Warning;

  static Future<TournamentIntegrityCode> default_() => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasTournamentIntegrityMessageTournamentIntegrityCodeDefault();

  static TournamentIntegrityCode fromJsonString({required String json}) =>
      TmsRustLib.instance.api
          .crateInfraDatabaseSchemasTournamentIntegrityMessageTournamentIntegrityCodeFromJsonString(
              json: json);

  String getMessage() => TmsRustLib.instance.api
          .crateInfraDatabaseSchemasTournamentIntegrityMessageTournamentIntegrityCodeGetMessage(
        that: this,
      );

  String getStringifiedCode() => TmsRustLib.instance.api
          .crateInfraDatabaseSchemasTournamentIntegrityMessageTournamentIntegrityCodeGetStringifiedCode(
        that: this,
      );

  String toJsonString() => TmsRustLib.instance.api
          .crateInfraDatabaseSchemasTournamentIntegrityMessageTournamentIntegrityCodeToJsonString(
        that: this,
      );

  static String toSchema() => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasTournamentIntegrityMessageTournamentIntegrityCodeToSchema();
}

class TournamentIntegrityMessage {
  final TournamentIntegrityCode integrityCode;
  final String message;
  final String? teamNumber;
  final String? matchNumber;
  final String? sessionNumber;

  const TournamentIntegrityMessage.raw({
    required this.integrityCode,
    required this.message,
    this.teamNumber,
    this.matchNumber,
    this.sessionNumber,
  });

  static Future<TournamentIntegrityMessage> default_() => TmsRustLib
      .instance.api
      .crateInfraDatabaseSchemasTournamentIntegrityMessageTournamentIntegrityMessageDefault();

  static TournamentIntegrityMessage fromJsonString({required String json}) =>
      TmsRustLib.instance.api
          .crateInfraDatabaseSchemasTournamentIntegrityMessageTournamentIntegrityMessageFromJsonString(
              json: json);

  factory TournamentIntegrityMessage(
          {required TournamentIntegrityCode integrityCode,
          String? teamNumber,
          String? matchNumber,
          String? sessionNumber}) =>
      TmsRustLib.instance.api
          .crateInfraDatabaseSchemasTournamentIntegrityMessageTournamentIntegrityMessageNew(
              integrityCode: integrityCode,
              teamNumber: teamNumber,
              matchNumber: matchNumber,
              sessionNumber: sessionNumber);

  String toJsonString() => TmsRustLib.instance.api
          .crateInfraDatabaseSchemasTournamentIntegrityMessageTournamentIntegrityMessageToJsonString(
        that: this,
      );

  static String toSchema() => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasTournamentIntegrityMessageTournamentIntegrityMessageToSchema();

  @override
  int get hashCode =>
      integrityCode.hashCode ^
      message.hashCode ^
      teamNumber.hashCode ^
      matchNumber.hashCode ^
      sessionNumber.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentIntegrityMessage &&
          runtimeType == other.runtimeType &&
          integrityCode == other.integrityCode &&
          message == other.message &&
          teamNumber == other.teamNumber &&
          matchNumber == other.matchNumber &&
          sessionNumber == other.sessionNumber;
}
