// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.1.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../../frb_generated.dart';
import '../category_question.dart';
import '../fll_blueprint.dart';
import '../mission.dart';
import '../question.dart';
import '../rule_engine.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class MasterPiece {
  const MasterPiece();

  Future<FllBlueprint> getFllGame() => TmsRustLib.instance.api
          .crateInfraFllInfraSeasonsFll2023MasterPieceGetFllGame(
        that: this,
      );

  Future<String> getSeason() => TmsRustLib.instance.api
          .crateInfraFllInfraSeasonsFll2023MasterPieceGetSeason(
        that: this,
      );

  Future<List<QuestionValidationError>> validate(
          {required Map<String, QuestionAnswer> answers}) =>
      TmsRustLib.instance.api
          .crateInfraFllInfraSeasonsFll2023MasterPieceValidate(
              that: this, answers: answers);

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasterPiece && runtimeType == other.runtimeType;
}
