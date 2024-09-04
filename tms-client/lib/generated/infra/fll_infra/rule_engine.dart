// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.3.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'question.dart';

// These functions are ignored because they are not marked as `pub`: `evaluate_condition`, `evaluate_expression`, `id_substitution`, `parse_condition`, `split_expression`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `fmt`

class QuestionRule {
  final String condition;
  final int output;

  const QuestionRule({
    required this.condition,
    required this.output,
  });

  Future<int> apply({required Map<String, QuestionAnswer> answers}) =>
      TmsRustLib.instance.api.crateInfraFllInfraRuleEngineQuestionRuleApply(
          that: this, answers: answers);

  Future<bool> evaluate({required Map<String, QuestionAnswer> answers}) =>
      TmsRustLib.instance.api.crateInfraFllInfraRuleEngineQuestionRuleEvaluate(
          that: this, answers: answers);

  // HINT: Make it `#[frb(sync)]` to let it become the default constructor of Dart class.
  static Future<QuestionRule> newInstance(
          {required String condition, required int output}) =>
      TmsRustLib.instance.api.crateInfraFllInfraRuleEngineQuestionRuleNew(
          condition: condition, output: output);

  @override
  int get hashCode => condition.hashCode ^ output.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionRule &&
          runtimeType == other.runtimeType &&
          condition == other.condition &&
          output == other.output;
}
