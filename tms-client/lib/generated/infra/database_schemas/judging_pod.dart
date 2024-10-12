// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.5.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `fmt`

class JudgingPod {
  final String podName;

  const JudgingPod({
    required this.podName,
  });

  static Future<JudgingPod> default_() => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasJudgingPodJudgingPodDefault();

  static JudgingPod fromJsonString({required String json}) => TmsRustLib
      .instance.api
      .crateInfraDatabaseSchemasJudgingPodJudgingPodFromJsonString(json: json);

  String toJsonString() => TmsRustLib.instance.api
          .crateInfraDatabaseSchemasJudgingPodJudgingPodToJsonString(
        that: this,
      );

  static String toSchema() => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasJudgingPodJudgingPodToSchema();

  @override
  int get hashCode => podName.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JudgingPod &&
          runtimeType == other.runtimeType &&
          podName == other.podName;
}
