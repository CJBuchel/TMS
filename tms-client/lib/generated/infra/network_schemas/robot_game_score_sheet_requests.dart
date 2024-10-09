// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.1.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import '../database_schemas/game_score_sheet.dart';
import '../database_schemas/tms_time/tms_date.dart';
import '../database_schemas/tms_time/tms_date_time.dart';
import '../database_schemas/tms_time/tms_time.dart';
import '../fll_infra/question.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `fmt`, `fmt`, `fmt`

class RobotGameScoreSheetInsertRequest {
  final String? scoreSheetId;
  final GameScoreSheet scoreSheet;

  const RobotGameScoreSheetInsertRequest({
    this.scoreSheetId,
    required this.scoreSheet,
  });

  static Future<RobotGameScoreSheetInsertRequest> default_() => TmsRustLib
      .instance.api
      .crateInfraNetworkSchemasRobotGameScoreSheetRequestsRobotGameScoreSheetInsertRequestDefault();

  static RobotGameScoreSheetInsertRequest fromJsonString(
          {required String json}) =>
      TmsRustLib.instance.api
          .crateInfraNetworkSchemasRobotGameScoreSheetRequestsRobotGameScoreSheetInsertRequestFromJsonString(
              json: json);

  String toJsonString() => TmsRustLib.instance.api
          .crateInfraNetworkSchemasRobotGameScoreSheetRequestsRobotGameScoreSheetInsertRequestToJsonString(
        that: this,
      );

  static String toSchema() => TmsRustLib.instance.api
      .crateInfraNetworkSchemasRobotGameScoreSheetRequestsRobotGameScoreSheetInsertRequestToSchema();

  @override
  int get hashCode => scoreSheetId.hashCode ^ scoreSheet.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RobotGameScoreSheetInsertRequest &&
          runtimeType == other.runtimeType &&
          scoreSheetId == other.scoreSheetId &&
          scoreSheet == other.scoreSheet;
}

class RobotGameScoreSheetRemoveRequest {
  final String scoreSheetId;

  const RobotGameScoreSheetRemoveRequest({
    required this.scoreSheetId,
  });

  static Future<RobotGameScoreSheetRemoveRequest> default_() => TmsRustLib
      .instance.api
      .crateInfraNetworkSchemasRobotGameScoreSheetRequestsRobotGameScoreSheetRemoveRequestDefault();

  static RobotGameScoreSheetRemoveRequest fromJsonString(
          {required String json}) =>
      TmsRustLib.instance.api
          .crateInfraNetworkSchemasRobotGameScoreSheetRequestsRobotGameScoreSheetRemoveRequestFromJsonString(
              json: json);

  String toJsonString() => TmsRustLib.instance.api
          .crateInfraNetworkSchemasRobotGameScoreSheetRequestsRobotGameScoreSheetRemoveRequestToJsonString(
        that: this,
      );

  static String toSchema() => TmsRustLib.instance.api
      .crateInfraNetworkSchemasRobotGameScoreSheetRequestsRobotGameScoreSheetRemoveRequestToSchema();

  @override
  int get hashCode => scoreSheetId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RobotGameScoreSheetRemoveRequest &&
          runtimeType == other.runtimeType &&
          scoreSheetId == other.scoreSheetId;
}

class RobotGameScoreSheetSubmitRequest {
  final String blueprintTitle;
  final String table;
  final String teamNumber;
  final String referee;
  final String? matchNumber;
  final String gp;
  final bool noShow;
  final int score;
  final int round;
  final bool isAgnostic;
  final List<QuestionAnswer> scoreSheetAnswers;
  final String privateComment;

  const RobotGameScoreSheetSubmitRequest({
    required this.blueprintTitle,
    required this.table,
    required this.teamNumber,
    required this.referee,
    this.matchNumber,
    required this.gp,
    required this.noShow,
    required this.score,
    required this.round,
    required this.isAgnostic,
    required this.scoreSheetAnswers,
    required this.privateComment,
  });

  static Future<RobotGameScoreSheetSubmitRequest> default_() => TmsRustLib
      .instance.api
      .crateInfraNetworkSchemasRobotGameScoreSheetRequestsRobotGameScoreSheetSubmitRequestDefault();

  static RobotGameScoreSheetSubmitRequest fromJsonString(
          {required String json}) =>
      TmsRustLib.instance.api
          .crateInfraNetworkSchemasRobotGameScoreSheetRequestsRobotGameScoreSheetSubmitRequestFromJsonString(
              json: json);

  String toJsonString() => TmsRustLib.instance.api
          .crateInfraNetworkSchemasRobotGameScoreSheetRequestsRobotGameScoreSheetSubmitRequestToJsonString(
        that: this,
      );

  static String toSchema() => TmsRustLib.instance.api
      .crateInfraNetworkSchemasRobotGameScoreSheetRequestsRobotGameScoreSheetSubmitRequestToSchema();

  @override
  int get hashCode =>
      blueprintTitle.hashCode ^
      table.hashCode ^
      teamNumber.hashCode ^
      referee.hashCode ^
      matchNumber.hashCode ^
      gp.hashCode ^
      noShow.hashCode ^
      score.hashCode ^
      round.hashCode ^
      isAgnostic.hashCode ^
      scoreSheetAnswers.hashCode ^
      privateComment.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RobotGameScoreSheetSubmitRequest &&
          runtimeType == other.runtimeType &&
          blueprintTitle == other.blueprintTitle &&
          table == other.table &&
          teamNumber == other.teamNumber &&
          referee == other.referee &&
          matchNumber == other.matchNumber &&
          gp == other.gp &&
          noShow == other.noShow &&
          score == other.score &&
          round == other.round &&
          isAgnostic == other.isAgnostic &&
          scoreSheetAnswers == other.scoreSheetAnswers &&
          privateComment == other.privateComment;
}
