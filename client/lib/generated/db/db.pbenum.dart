// This is a generated file - do not edit.
//
// Generated from db/db.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Season extends $pb.ProtobufEnum {
  static const Season AGNOSTIC = Season._(0, _omitEnumNames ? '' : 'AGNOSTIC');
  static const Season SEASON_2025 =
      Season._(10, _omitEnumNames ? '' : 'SEASON_2025');

  static const $core.List<Season> values = <Season>[
    AGNOSTIC,
    SEASON_2025,
  ];

  static final $core.Map<$core.int, Season> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Season? valueOf($core.int value) => _byValue[value];

  const Season._(super.value, super.name);
}

class MatchType extends $pb.ProtobufEnum {
  static const MatchType RANKING =
      MatchType._(0, _omitEnumNames ? '' : 'RANKING');
  static const MatchType PRACTICE =
      MatchType._(1, _omitEnumNames ? '' : 'PRACTICE');

  static const $core.List<MatchType> values = <MatchType>[
    RANKING,
    PRACTICE,
  ];

  static final $core.List<MatchType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static MatchType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MatchType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
