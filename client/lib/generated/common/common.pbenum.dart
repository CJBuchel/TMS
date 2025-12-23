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

class IntegrityCode extends $pb.ProtobufEnum {
  /// Errors
  static const IntegrityCode E000 =
      IntegrityCode._(0, _omitEnumNames ? '' : 'E000');
  static const IntegrityCode E001 =
      IntegrityCode._(1, _omitEnumNames ? '' : 'E001');
  static const IntegrityCode E002 =
      IntegrityCode._(2, _omitEnumNames ? '' : 'E002');
  static const IntegrityCode E003 =
      IntegrityCode._(3, _omitEnumNames ? '' : 'E003');
  static const IntegrityCode E004 =
      IntegrityCode._(4, _omitEnumNames ? '' : 'E004');
  static const IntegrityCode E005 =
      IntegrityCode._(5, _omitEnumNames ? '' : 'E005');
  static const IntegrityCode E006 =
      IntegrityCode._(6, _omitEnumNames ? '' : 'E006');
  static const IntegrityCode E007 =
      IntegrityCode._(7, _omitEnumNames ? '' : 'E007');
  static const IntegrityCode E008 =
      IntegrityCode._(8, _omitEnumNames ? '' : 'E008');
  static const IntegrityCode E009 =
      IntegrityCode._(9, _omitEnumNames ? '' : 'E009');
  static const IntegrityCode E010 =
      IntegrityCode._(10, _omitEnumNames ? '' : 'E010');
  static const IntegrityCode E011 =
      IntegrityCode._(11, _omitEnumNames ? '' : 'E011');
  static const IntegrityCode E012 =
      IntegrityCode._(12, _omitEnumNames ? '' : 'E012');
  static const IntegrityCode E013 =
      IntegrityCode._(13, _omitEnumNames ? '' : 'E013');

  /// Warnings - starts at 1000 for future
  static const IntegrityCode W000 =
      IntegrityCode._(1000, _omitEnumNames ? '' : 'W000');
  static const IntegrityCode W001 =
      IntegrityCode._(1001, _omitEnumNames ? '' : 'W001');
  static const IntegrityCode W002 =
      IntegrityCode._(1002, _omitEnumNames ? '' : 'W002');
  static const IntegrityCode W003 =
      IntegrityCode._(1003, _omitEnumNames ? '' : 'W003');
  static const IntegrityCode W004 =
      IntegrityCode._(1004, _omitEnumNames ? '' : 'W004');
  static const IntegrityCode W005 =
      IntegrityCode._(1005, _omitEnumNames ? '' : 'W005');
  static const IntegrityCode W006 =
      IntegrityCode._(1006, _omitEnumNames ? '' : 'W006');
  static const IntegrityCode W007 =
      IntegrityCode._(1007, _omitEnumNames ? '' : 'W007');
  static const IntegrityCode W008 =
      IntegrityCode._(1008, _omitEnumNames ? '' : 'W008');
  static const IntegrityCode W009 =
      IntegrityCode._(1009, _omitEnumNames ? '' : 'W009');
  static const IntegrityCode W010 =
      IntegrityCode._(1010, _omitEnumNames ? '' : 'W010');
  static const IntegrityCode W011 =
      IntegrityCode._(1011, _omitEnumNames ? '' : 'W011');
  static const IntegrityCode W012 =
      IntegrityCode._(1012, _omitEnumNames ? '' : 'W012');
  static const IntegrityCode W013 =
      IntegrityCode._(1013, _omitEnumNames ? '' : 'W013');
  static const IntegrityCode W014 =
      IntegrityCode._(1014, _omitEnumNames ? '' : 'W014');
  static const IntegrityCode W015 =
      IntegrityCode._(1015, _omitEnumNames ? '' : 'W015');
  static const IntegrityCode W016 =
      IntegrityCode._(1016, _omitEnumNames ? '' : 'W016');
  static const IntegrityCode W017 =
      IntegrityCode._(1017, _omitEnumNames ? '' : 'W017');
  static const IntegrityCode W018 =
      IntegrityCode._(1018, _omitEnumNames ? '' : 'W018');

  static const $core.List<IntegrityCode> values = <IntegrityCode>[
    E000,
    E001,
    E002,
    E003,
    E004,
    E005,
    E006,
    E007,
    E008,
    E009,
    E010,
    E011,
    E012,
    E013,
    W000,
    W001,
    W002,
    W003,
    W004,
    W005,
    W006,
    W007,
    W008,
    W009,
    W010,
    W011,
    W012,
    W013,
    W014,
    W015,
    W016,
    W017,
    W018,
  ];

  static final $core.Map<$core.int, IntegrityCode> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static IntegrityCode? valueOf($core.int value) => _byValue[value];

  const IntegrityCode._(super.value, super.name);
}

class IntegritySeverity extends $pb.ProtobufEnum {
  static const IntegritySeverity UNSPECIFIED =
      IntegritySeverity._(0, _omitEnumNames ? '' : 'UNSPECIFIED');
  static const IntegritySeverity ERROR =
      IntegritySeverity._(1, _omitEnumNames ? '' : 'ERROR');
  static const IntegritySeverity WARNING =
      IntegritySeverity._(2, _omitEnumNames ? '' : 'WARNING');

  static const $core.List<IntegritySeverity> values = <IntegritySeverity>[
    UNSPECIFIED,
    ERROR,
    WARNING,
  ];

  static final $core.List<IntegritySeverity?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static IntegritySeverity? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const IntegritySeverity._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
