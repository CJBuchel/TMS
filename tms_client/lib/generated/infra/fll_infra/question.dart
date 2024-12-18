// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.6.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'category_question.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:freezed_annotation/freezed_annotation.dart' hide protected;
import 'rule_engine.dart';
part 'question.freezed.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `clone`, `clone`, `fmt`, `fmt`, `fmt`

class Question {
  final String id;
  final String label;
  final String labelShort;
  final QuestionInput input;
  final List<QuestionRule> rules;

  const Question({
    required this.id,
    required this.label,
    required this.labelShort,
    required this.input,
    required this.rules,
  });

  static Question default_() =>
      TmsRustLib.instance.api.crateInfraFllInfraQuestionQuestionDefault();

  static Question fromJsonString({required String json}) =>
      TmsRustLib.instance.api
          .crateInfraFllInfraQuestionQuestionFromJsonString(json: json);

  int getScore({required Map<String, QuestionAnswer> answers}) => TmsRustLib
      .instance.api
      .crateInfraFllInfraQuestionQuestionGetScore(that: this, answers: answers);

  String toJsonString() =>
      TmsRustLib.instance.api.crateInfraFllInfraQuestionQuestionToJsonString(
        that: this,
      );

  static String toSchema() =>
      TmsRustLib.instance.api.crateInfraFllInfraQuestionQuestionToSchema();

  @override
  int get hashCode =>
      id.hashCode ^
      label.hashCode ^
      labelShort.hashCode ^
      input.hashCode ^
      rules.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          labelShort == other.labelShort &&
          input == other.input &&
          rules == other.rules;
}

class QuestionAnswer {
  final String questionId;
  final String answer;

  const QuestionAnswer({
    required this.questionId,
    required this.answer,
  });

  static QuestionAnswer default_() =>
      TmsRustLib.instance.api.crateInfraFllInfraQuestionQuestionAnswerDefault();

  static QuestionAnswer fromJsonString({required String json}) =>
      TmsRustLib.instance.api
          .crateInfraFllInfraQuestionQuestionAnswerFromJsonString(json: json);

  String toJsonString() => TmsRustLib.instance.api
          .crateInfraFllInfraQuestionQuestionAnswerToJsonString(
        that: this,
      );

  static String toSchema() => TmsRustLib.instance.api
      .crateInfraFllInfraQuestionQuestionAnswerToSchema();

  @override
  int get hashCode => questionId.hashCode ^ answer.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionAnswer &&
          runtimeType == other.runtimeType &&
          questionId == other.questionId &&
          answer == other.answer;
}

@freezed
sealed class QuestionInput with _$QuestionInput {
  const QuestionInput._();

  const factory QuestionInput.categorical(
    CategoricalQuestion field0,
  ) = QuestionInput_Categorical;
}

class QuestionValidationError {
  final String questionIds;
  final String message;

  const QuestionValidationError({
    required this.questionIds,
    required this.message,
  });

  @override
  int get hashCode => questionIds.hashCode ^ message.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionValidationError &&
          runtimeType == other.runtimeType &&
          questionIds == other.questionIds &&
          message == other.message;
}
