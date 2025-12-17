// This is a generated file - do not edit.
//
// Generated from common/common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Role extends $pb.ProtobufEnum {
  static const Role ADMIN = Role._(0, _omitEnumNames ? '' : 'ADMIN');
  static const Role REFEREE = Role._(1, _omitEnumNames ? '' : 'REFEREE');
  static const Role HEAD_REFEREE =
      Role._(2, _omitEnumNames ? '' : 'HEAD_REFEREE');
  static const Role JUDGE = Role._(3, _omitEnumNames ? '' : 'JUDGE');
  static const Role JUDGE_ADVISOR =
      Role._(4, _omitEnumNames ? '' : 'JUDGE_ADVISOR');
  static const Role SCORE_KEEPER =
      Role._(5, _omitEnumNames ? '' : 'SCORE_KEEPER');
  static const Role EMCEE = Role._(6, _omitEnumNames ? '' : 'EMCEE');
  static const Role AV = Role._(7, _omitEnumNames ? '' : 'AV');

  static const $core.List<Role> values = <Role>[
    ADMIN,
    REFEREE,
    HEAD_REFEREE,
    JUDGE,
    JUDGE_ADVISOR,
    SCORE_KEEPER,
    EMCEE,
    AV,
  ];

  static final $core.List<Role?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static Role? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Role._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
